import { initEcho, getEcho, subscribeToAttendanceUpdates, unsubscribeFromAttendanceUpdates } from './echo';

// Mock Echo and Pusher
jest.mock('laravel-echo', () => {
  return function() {
    return {
      channel: jest.fn().mockReturnThis(),
      listen: jest.fn().mockReturnThis(),
      leave: jest.fn()
    };
  };
});

jest.mock('pusher-js');

describe('Echo WebSockets Utilities', () => {
  let originalWindow;
  
  beforeEach(() => {
    // Save original window
    originalWindow = global.window;
    
    // Mock window for testing
    global.window = Object.create(window);
    global.window.Pusher = null;
  });
  
  afterEach(() => {
    // Restore original window
    global.window = originalWindow;
    
    // Reset mocks
    jest.clearAllMocks();
  });
  
  test('initEcho initializes Echo instance on client side', () => {
    const echo = initEcho();
    
    expect(echo).not.toBeNull();
    expect(global.window.Pusher).not.toBeNull();
  });
  
  test('getEcho returns existing Echo instance if available', () => {
    const echo1 = initEcho();
    const echo2 = getEcho();
    
    expect(echo1).toBe(echo2);
  });
  
  test('getEcho initializes Echo if not already initialized', () => {
    const echo = getEcho();
    
    expect(echo).not.toBeNull();
  });
  
  test('subscribeToAttendanceUpdates subscribes to attendance channel', () => {
    const callback = jest.fn();
    const echo = initEcho();
    
    subscribeToAttendanceUpdates(callback);
    
    expect(echo.channel).toHaveBeenCalledWith('attendance');
    expect(echo.listen).toHaveBeenCalledWith('.attendance.updated', expect.any(Function));
  });
  
  test('subscribeToAttendanceUpdates returns null if Echo not initialized', () => {
    // Make getEcho return null
    jest.spyOn(global, 'getEcho').mockReturnValueOnce(null);
    
    const result = subscribeToAttendanceUpdates(jest.fn());
    
    expect(result).toBeNull();
  });
  
  test('unsubscribeFromAttendanceUpdates leaves attendance channel', () => {
    const echo = initEcho();
    
    unsubscribeFromAttendanceUpdates();
    
    expect(echo.leave).toHaveBeenCalledWith('attendance');
  });
  
  test('unsubscribeFromAttendanceUpdates does nothing if Echo not initialized', () => {
    // Make getEcho return null
    jest.spyOn(global, 'getEcho').mockReturnValueOnce(null);
    
    // This should not throw an error
    unsubscribeFromAttendanceUpdates();
  });
});
