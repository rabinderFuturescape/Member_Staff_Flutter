<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Firebase\JWT\ExpiredException;
use Firebase\JWT\SignatureInvalidException;
use Symfony\Component\HttpFoundation\Response;

class VerifyKeycloakToken
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json([
                'success' => false,
                'message' => 'Authorization token not found',
            ], 401);
        }

        try {
            // Get the Keycloak public key from config
            $publicKey = config('keycloak.public_key');
            
            if (!$publicKey) {
                throw new \Exception('Keycloak public key not configured');
            }
            
            // Format the public key correctly
            $publicKey = "-----BEGIN PUBLIC KEY-----\n" . 
                         chunk_split($publicKey, 64, "\n") . 
                         "-----END PUBLIC KEY-----";
            
            // Decode the token
            $decoded = JWT::decode($token, new Key($publicKey, 'RS256'));
            
            // Verify the token issuer
            $expectedIssuer = config('keycloak.realm_url');
            if ($decoded->iss !== $expectedIssuer) {
                throw new \Exception('Invalid token issuer');
            }
            
            // Verify the token audience
            $expectedAudience = config('keycloak.client_id');
            if (!in_array($expectedAudience, (array)$decoded->aud)) {
                throw new \Exception('Invalid token audience');
            }
            
            // Add the decoded token to the request
            $request->merge(['token_payload' => (array) $decoded]);
            
            // Extract user information from the token
            $request->merge([
                'user_id' => $decoded->sub ?? null,
                'member_id' => $decoded->member_id ?? null,
                'unit_id' => $decoded->unit_id ?? null,
                'company_id' => $decoded->company_id ?? null,
                'user_roles' => $decoded->realm_access->roles ?? [],
            ]);

            return $next($request);
        } catch (ExpiredException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token has expired',
            ], 401);
        } catch (SignatureInvalidException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid token signature',
            ], 401);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid token: ' . $e->getMessage(),
            ], 401);
        }
    }
}
