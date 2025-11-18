<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use RuntimeException;

class GoogleCloudStorage
{
    protected ?string $cachedToken = null;
    protected int $tokenExpiry = 0;

    public function upload(UploadedFile $file, string $path, string $visibility = 'publicRead'): string
    {
        $bucket = $this->bucket();
        $token = $this->accessToken();

        $response = Http::withToken($token)
            ->withHeaders([
                'Content-Type' => $file->getMimeType() ?: 'application/octet-stream',
            ])
            ->send('POST', "https://storage.googleapis.com/upload/storage/v1/b/{$bucket}/o", [
                'query' => [
                    'uploadType' => 'media',
                    'name' => $path,
                    'predefinedAcl' => $visibility,
                ],
                'body' => $file->get(),
            ]);

        if ($response->failed()) {
            throw new RuntimeException('Failed to upload icon to Google Cloud Storage: '.$response->body());
        }

        return $this->publicUrl($path);
    }

    public function delete(string $path): void
    {
        $bucket = $this->bucket();
        $token = $this->accessToken();

        Http::withToken($token)
            ->send('DELETE', "https://storage.googleapis.com/storage/v1/b/{$bucket}/o/".rawurlencode($path));
    }

    public function publicUrl(string $path): string
    {
        return sprintf('https://storage.googleapis.com/%s/%s', $this->bucket(), ltrim($path, '/'));
    }

    protected function bucket(): string
    {
        return config('services.gcs.bucket', 'tracker-expenses');
    }

    protected function accessToken(): string
    {
        if ($this->cachedToken && $this->tokenExpiry > time() + 60) {
            return $this->cachedToken;
        }

        $credentials = $this->credentials();
        $header = $this->base64UrlEncode(json_encode(['alg' => 'RS256', 'typ' => 'JWT'], JSON_THROW_ON_ERROR));
        $now = time();
        $payload = $this->base64UrlEncode(json_encode([
            'iss' => $credentials['client_email'],
            'scope' => 'https://www.googleapis.com/auth/devstorage.read_write',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600,
        ], JSON_THROW_ON_ERROR));

        $signature = $this->sign($header.'.'.$payload, $credentials['private_key']);
        $jwt = $header.'.'.$payload.'.'.$signature;

        $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt,
        ])->throw()->json();

        $this->cachedToken = $response['access_token'];
        $this->tokenExpiry = $now + (int) ($response['expires_in'] ?? 3600);

        return $this->cachedToken;
    }

    protected function credentials(): array
    {
        $credentials = [
            'client_email' => config('services.gcs.client_email'),
            'private_key' => config('services.gcs.private_key'),
        ];

        if (! $credentials['client_email'] || ! $credentials['private_key']) {
            throw new RuntimeException('Google Cloud Storage credentials are not configured.');
        }

        $credentials['private_key'] = $this->normalizeKey($credentials['private_key']);

        return $credentials;
    }

    protected function normalizeKey(string $key): string
    {
        if (Str::contains($key, '\n')) {
            $key = str_replace('\n', "\n", $key);
        }

        return $key;
    }

    protected function sign(string $data, string $privateKey): string
    {
        $success = openssl_sign($data, $signature, $privateKey, 'sha256WithRSAEncryption');

        if (! $success) {
            throw new RuntimeException('Failed to sign JWT for Google Cloud Storage.');
        }

        return $this->base64UrlEncode($signature);
    }

    protected function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
