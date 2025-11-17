/*{
  "version": 2,
  "buildCommand": "echo 'Using pre-built files from build/web'",
  "outputDirectory": "build/web",
  "installCommand": "echo 'No install needed'",
  "routes": [
    {
      "src": "/assets/(.*)",
      "dest": "/assets/$1"
    },
    {
      "src": "/icons/(.*)",
      "dest": "/icons/$1"
    },
    {
      "src": "/canvaskit/(.*)",
      "dest": "/canvaskit/$1"
    },
    {
      "src": "/favicon.png",
      "dest": "/favicon.png"
    },
    {
      "src": "/manifest.json",
      "dest": "/manifest.json"
    },
    {
      "handle": "filesystem"
    },
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
*/