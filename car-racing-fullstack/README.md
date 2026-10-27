# Turbo Racer — Docker Full-Stack Game

Frontend: HTML/CSS/JavaScript (Nginx). Backend: Python Flask REST API. Database: SQLite in a persistent Docker volume.

## Run on Windows with Docker Desktop
1. Extract the ZIP and open this folder in VS Code.
2. Open Terminal > New Terminal.
3. Run `docker compose up --build -d`.
4. Open http://localhost:8092 to play.
5. Open http://localhost:8092/api/health to test the backend.
6. Run `docker compose ps` to see both containers.
7. Run `docker compose logs -f` for logs (Ctrl+C to stop following).
8. Run `docker compose down` to stop the project (scores remain saved in the Docker volume).

If port 8092 is busy, change `8092:80` in compose.yaml to `8093:80`, then run `docker compose up -d` and open http://localhost:8093.

Note: This is a beginner demo. Scores are not authenticated, so users can submit scores manually through the API.
