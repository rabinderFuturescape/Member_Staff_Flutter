import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/chat_list_page.dart';
import 'pages/chat_room_page.dart';
import 'pages/create_room_page.dart';
import 'providers/chat_provider.dart';
import 'utils/chat_constants.dart';

/// Module for Chat Service feature
class ChatServiceModule {
  /// Private constructor to prevent instantiation
  ChatServiceModule._();
  
  /// Register routes for this module
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      ChatConstants.chatListRoute: (context) => const ChatListPage(),
      ChatConstants.chatRoomRoute: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return ChatRoomPage(roomId: args['roomId']);
      },
      ChatConstants.createRoomRoute: (context) => const CreateRoomPage(),
    };
  }
  
  /// Register providers for this module
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider<ChatProvider>(
        create: (context) => ChatProvider(
          supabase: Supabase.instance.client,
          currentUserId: Supabase.instance.client.auth.currentUser!.id,
        ),
      ),
    ];
  }
  
  /// Initialize the module
  static Future<void> initialize() async {
    // Any initialization logic can go here
    // For example, setting up Supabase realtime subscriptions
  }
  
  /// Create SQL schema for the module
  static String getDatabaseSchema() {
    return '''
-- Chat Rooms Table
CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    type VARCHAR(10) NOT NULL CHECK (type IN ('direct', 'group', 'public')),
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

-- Add tables to the publication to enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_room_participants;
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_chat_messages_room_id ON public.chat_messages(room_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_chat_room_participants_user_id ON public.chat_room_participants(user_id);

-- Create RLS policies
-- Enable RLS on tables
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

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
''';
  }
}
