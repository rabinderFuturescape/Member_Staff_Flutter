import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

// Initialize Echo only on the client side
let echoInstance = null;

export function initEcho() {
  if (typeof window !== 'undefined' && !echoInstance) {
    window.Pusher = Pusher;
    
    echoInstance = new Echo({
      broadcaster: 'pusher',
      key: process.env.NEXT_PUBLIC_PUSHER_APP_KEY || 'member_staff_app_key',
      wsHost: process.env.NEXT_PUBLIC_WEBSOCKET_HOST || 'localhost',
      wsPort: process.env.NEXT_PUBLIC_WEBSOCKET_PORT || 6001,
      wssPort: process.env.NEXT_PUBLIC_WEBSOCKET_PORT || 6001,
      forceTLS: false,
      disableStats: true,
      enabledTransports: ['ws', 'wss'],
    });
  }
  
  return echoInstance;
}

export function getEcho() {
  if (!echoInstance && typeof window !== 'undefined') {
    return initEcho();
  }
  
  return echoInstance;
}

export function subscribeToAttendanceUpdates(callback) {
  const echo = getEcho();
  
  if (!echo) {
    console.error('Echo not initialized');
    return null;
  }
  
  return echo.channel('attendance')
    .listen('.attendance.updated', (data) => {
      if (callback && typeof callback === 'function') {
        callback(data);
      }
    });
}

export function unsubscribeFromAttendanceUpdates() {
  const echo = getEcho();
  
  if (!echo) {
    return;
  }
  
  echo.leave('attendance');
}
