<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Keycloak Configuration
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials and configuration for Keycloak
    | integration with the OneSSO authentication system.
    |
    */

    // The base URL of the Keycloak server
    'base_url' => env('KEYCLOAK_BASE_URL', 'https://sso.oneapp.in'),
    
    // The realm name
    'realm' => env('KEYCLOAK_REALM', 'oneapp'),
    
    // The full realm URL (used for token validation)
    'realm_url' => env('KEYCLOAK_REALM_URL', 'https://sso.oneapp.in/auth/realms/oneapp'),
    
    // The client ID
    'client_id' => env('KEYCLOAK_CLIENT_ID', 'member-staff-api'),
    
    // The client secret
    'client_secret' => env('KEYCLOAK_CLIENT_SECRET', ''),
    
    // The Keycloak public key (without BEGIN/END PUBLIC KEY headers)
    'public_key' => env('KEYCLOAK_PUBLIC_KEY', ''),
    
    // The token expiration time in seconds
    'token_expiration' => env('KEYCLOAK_TOKEN_EXPIRATION', 300),
    
    // The minimum time before token expiration to refresh (in seconds)
    'token_refresh_threshold' => env('KEYCLOAK_TOKEN_REFRESH_THRESHOLD', 60),
];
