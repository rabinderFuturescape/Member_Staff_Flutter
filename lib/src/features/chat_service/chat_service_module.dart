import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/chat_list_page.dart';
import 'pages/chat_room_page.dart';
import 'pages/create_room_page.dart';
import 'pages/committee_room_creation_page.dart';
import 'providers/keycloak_chat_provider.dart';
import 'services/chat_auth_service.dart';
import 'utils/chat_constants.dart';

/// Module for Chat Service feature
class ChatServiceModule {
  /// Private constructor to prevent instantiation
  ChatServiceModule._();

  /// Register routes for this module
  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      ChatConstants.chatListRoute: (context) => const ChatListPage(),
      ChatConstants.chatRoomRoute: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ChatRoomPage(roomId: args['roomId']);
      },
      ChatConstants.createRoomRoute: (context) => const CreateRoomPage(),
      ChatConstants.createCommitteeRoomRoute: (context) => const CommitteeRoomCreationPage(),
      ChatConstants.oneSSOLoginRoute: (context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      ChatConstants.oneSSOCallbackRoute: (context) => const Scaffold(
        body: Center(child: Text('Processing authentication...')),
      ),
    };
  }

  /// Register providers for this module
  static List<dynamic> getProviders() {
    return [
      ChangeNotifierProvider<KeycloakChatProvider>(
        create: (context) => KeycloakChatProvider(
          supabase: Supabase.instance.client,
          authService: ChatAuthService(),
        ),
      ),
    ];
  }

  /// Initialize the module
  static Future<void> initialize() async {
    // Initialize Supabase
    await Supabase.initialize(
      url: ChatConstants.supabaseUrl,
      anonKey: ChatConstants.supabaseAnonKey,
    );
  }

  /// Create SQL schema for the module
  static String getDatabaseSchema() {
    return '''
-- Chat Rooms Table
CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    type VARCHAR(10) NOT NULL CHECK (type IN ('direct', 'group', 'public', 'committee')),
    topic VARCHAR(100),
    is_committee_room BOOLEAN DEFAULT FALSE,
    created_by_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    last_message_content VARCHAR(1000),
    last_message_at TIMESTAMP WITH TIME ZONE
);

-- Chat Room Participants Table
CREATE TABLE IF NOT EXISTS public.chat_room_participants (
    room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    PRIMARY KEY (room_id, user_id)
);

-- Chat Messages Table
CREATE TABLE IF NOT EXISTS public.chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    content VARCHAR(1000) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Voting Polls Table
CREATE TABLE IF NOT EXISTS public.voting_polls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE NOT NULL,
    created_by_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    question TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    ends_at TIMESTAMP WITH TIME ZONE
);

-- Voting Options Table
CREATE TABLE IF NOT EXISTS public.voting_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    poll_id UUID REFERENCES public.voting_polls(id) ON DELETE CASCADE NOT NULL,
    option_text TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Voting Responses Table
CREATE TABLE IF NOT EXISTS public.voting_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    poll_id UUID REFERENCES public.voting_polls(id) ON DELETE CASCADE NOT NULL,
    option_id UUID REFERENCES public.voting_options(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(poll_id, user_id)
);

-- Add tables to the publication to enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_room_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.voting_polls;
ALTER PUBLICATION supabase_realtime ADD TABLE public.voting_options;
ALTER PUBLICATION supabase_realtime ADD TABLE public.voting_responses;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON public.chat_messages(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_room_participants_user_id ON public.chat_room_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_voting_polls_room_id ON public.voting_polls(room_id);
CREATE INDEX IF NOT EXISTS idx_voting_options_poll_id ON public.voting_options(poll_id);
CREATE INDEX IF NOT EXISTS idx_voting_responses_poll_id ON public.voting_responses(poll_id);
CREATE INDEX IF NOT EXISTS idx_voting_responses_user_id ON public.voting_responses(user_id);

-- Create RLS policies
-- Enable RLS on tables
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.voting_responses ENABLE ROW LEVEL SECURITY;

-- Chat Rooms Policies
CREATE POLICY "Users can view rooms they are in" ON public.chat_rooms
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_room_participants
            WHERE room_id = public.chat_rooms.id AND user_id = auth.uid()
        )
        OR
        public.chat_rooms.type = 'public'
    );

CREATE POLICY "Users can create rooms" ON public.chat_rooms
    FOR INSERT WITH CHECK (auth.uid() = created_by_id);

-- Chat Room Participants Policies
CREATE POLICY "Users can view room participants" ON public.chat_room_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_room_participants
            WHERE room_id = public.chat_room_participants.room_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can join public rooms" ON public.chat_room_participants
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.chat_rooms
            WHERE id = public.chat_room_participants.room_id AND type = 'public'
        )
    );

CREATE POLICY "Users can leave rooms" ON public.chat_room_participants
    FOR DELETE USING (auth.uid() = user_id);

-- Chat Messages Policies
CREATE POLICY "Users can view messages in rooms they are in" ON public.chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_room_participants
            WHERE room_id = public.chat_messages.room_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can send messages to rooms they are in" ON public.chat_messages
    FOR INSERT WITH CHECK (
        auth.uid() = sender_id AND
        EXISTS (
            SELECT 1 FROM public.chat_room_participants
            WHERE room_id = public.chat_messages.room_id AND user_id = auth.uid()
        )
    );

-- Voting Polls Policies
CREATE POLICY "Users can view polls in rooms they are in" ON public.voting_polls
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_room_participants
            WHERE room_id = public.voting_polls.room_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Committee members can create polls" ON public.voting_polls
    FOR INSERT WITH CHECK (
        auth.uid() = created_by_id AND
        EXISTS (
            SELECT 1 FROM public.chat_rooms
            WHERE id = public.voting_polls.room_id AND is_committee_room = TRUE
        )
    );

CREATE POLICY "Poll creators can update their polls" ON public.voting_polls
    FOR UPDATE USING (
        auth.uid() = created_by_id
    );

-- Voting Options Policies
CREATE POLICY "Users can view options for polls they can see" ON public.voting_options
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.voting_polls
            JOIN public.chat_room_participants ON public.voting_polls.room_id = public.chat_room_participants.room_id
            WHERE public.voting_polls.id = public.voting_options.poll_id
            AND public.chat_room_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Committee members can create options" ON public.voting_options
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.voting_polls
            WHERE id = public.voting_options.poll_id AND created_by_id = auth.uid()
        )
    );

-- Voting Responses Policies
CREATE POLICY "Users can view responses for polls they can see" ON public.voting_responses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.voting_polls
            JOIN public.chat_room_participants ON public.voting_polls.room_id = public.chat_room_participants.room_id
            WHERE public.voting_polls.id = public.voting_responses.poll_id
            AND public.chat_room_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can vote in polls for rooms they are in" ON public.voting_responses
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.voting_polls
            JOIN public.chat_room_participants ON public.voting_polls.room_id = public.chat_room_participants.room_id
            WHERE public.voting_polls.id = public.voting_responses.poll_id
            AND public.chat_room_participants.user_id = auth.uid()
            AND public.voting_polls.is_active = TRUE
        )
    );

CREATE POLICY "Users can update their votes" ON public.voting_responses
    FOR UPDATE USING (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM public.voting_polls
            WHERE id = public.voting_responses.poll_id AND is_active = TRUE
        )
    );

-- Create function to count votes for a poll
CREATE OR REPLACE FUNCTION public.get_vote_counts_for_poll(poll_id_param UUID)
RETURNS TABLE (option_id UUID, count BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        vr.option_id,
        COUNT(vr.id) AS count
    FROM
        public.voting_responses vr
    WHERE
        vr.poll_id = poll_id_param
    GROUP BY
        vr.option_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
''';
  }
}
