<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>3D Car Racing Game</title>

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    background: #101820;
    color: white;
    font-family: Arial, sans-serif;
    text-align: center;
    overflow: hidden;
}

h1 {
    padding: 15px;
    color: #00ffcc;
}

#game {
    width: 400px;
    height: 600px;
    margin: auto;
    position: relative;
    overflow: hidden;
    background: #333;
    border: 4px solid white;
    perspective: 600px;
}

.road {
    width: 100%;
    height: 100%;
    position: absolute;
    background: linear-gradient(
        90deg,
        #228b22 0%,
        #555 15%,
        #333 50%,
        #555 85%,
        #228b22 100%
    );
}

.line {
    width: 10px;
    height: 100px;
    background: white;
    position: absolute;
    left: 195px;
}

.car {
    width: 55px;
    height: 100px;
    position: absolute;
    border-radius: 12px;
    box-shadow: 5px 8px 12px #0008;
}

#player {
    background: linear-gradient(
        90deg,
        #990000,
        red,
        #ff5555,
        red,
        #990000
    );
    bottom: 30px;
    left: 170px;
    z-index: 5;
}

.car::before {
    content: "";
    position: absolute;
    top: 15px;
    left: 8px;
    width: 39px;
    height: 25px;
    background: #87ceeb;
    border-radius: 6px;
}

.car::after {
    content: "";
    position: absolute;
    bottom: 12px;
    left: 8px;
    width: 39px;
    height: 20px;
    background: #222;
    border-radius: 5px;
}

.enemy {
    background: linear-gradient(
        90deg,
        #002266,
        #0088ff,
        #66ccff,
        #0088ff,
        #002266
    );
    z-index: 4;
}

#score {
    position: absolute;
    top: 15px;
    left: 15px;
    font-size: 20px;
    z-index: 10;
    background: #0009;
    padding: 10px;
    border-radius: 8px;
}

#menu {
    position: absolute;
    top: 35%;
    width: 100%;
    z-index: 20;
}

button {
    padding: 15px 30px;
    background: #00ffcc;
    border: none;
    border-radius: 10px;
    font-size: 20px;
    cursor: pointer;
    font-weight: bold;
}

button:hover {
    background: yellow;
}

#controls {
    margin: 12px;
}

.control-btn {
    margin: 5px;
    padding: 12px 30px;
}
</style>
</head>

<body>

<h1>🏎️ 3D CAR RACING GAME</h1>

<div id="game">

    <div class="road"></div>

    <div id="score">Score: 0</div>

    <div id="player" class="car"></div>

    <div id="menu">
        <h2 id="message">CAR RACING</h2>
        <br>
        <button onclick="startGame()">START GAME</button>
    </div>

</div>

<div id="controls">
    <button class="control-btn" id="leftBtn">⬅ LEFT</button>
    <button class="control-btn" id="rightBtn">RIGHT ➡</button>
</div>

<script>
const game = document.getElementById("game");
const player = document.getElementById("player");
const scoreText = document.getElementById("score");
const menu = document.getElementById("menu");
const message = document.getElementById("message");

let playerX = 170;
let score = 0;
let speed = 5;
let running = false;
let enemies = [];
let lines = [];
let keys = {
    left: false,
    right: false
};

let animationId;
let spawnTimer = 0;

document.addEventListener("keydown", (e) => {
    if (e.key === "ArrowLeft" || e.key.toLowerCase() === "a") {
        keys.left = true;
        e.preventDefault();
    }

    if (e.key === "ArrowRight" || e.key.toLowerCase() === "d") {
        keys.right = true;
        e.preventDefault();
    }
});

document.addEventListener("keyup", (e) => {
    if (e.key === "ArrowLeft" || e.key.toLowerCase() === "a") {
        keys.left = false;
    }

    if (e.key === "ArrowRight" || e.key.toLowerCase() === "d") {
        keys.right = false;
    }
});

function setupButton(id, direction) {
    const btn = document.getElementById(id);

    btn.addEventListener("pointerdown", (e) => {
        e.preventDefault();
        keys[direction] = true;
    });

    btn.addEventListener("pointerup", () => {
        keys[direction] = false;
    });

    btn.addEventListener("pointerleave", () => {
        keys[direction] = false;
    });

    btn.addEventListener("pointercancel", () => {
        keys[direction] = false;
    });
}

setupButton("leftBtn", "left");
setupButton("rightBtn", "right");

function createRoad() {
    lines.forEach(line => line.remove());
    lines = [];

    for (let i = 0; i < 6; i++) {
        const line = document.createElement("div");
        line.className = "line";
        line.style.top = (i * 120 - 120) + "px";

        game.appendChild(line);
        lines.push(line);
    }
}

function createEnemy() {
    const enemy = document.createElement("div");

    enemy.className = "car enemy";

    const lanes = [70, 170, 270];
    const lane = lanes[Math.floor(Math.random() * lanes.length)];

    enemy.style.left = lane + "px";
    enemy.style.top = "-120px";

    game.appendChild(enemy);

    enemies.push({
        element: enemy,
        x: lane,
        y: -120
    });
}

function startGame() {
    cancelAnimationFrame(animationId);

    enemies.forEach(enemy => enemy.element.remove());
    enemies = [];

    score = 0;
    speed = 5;
    spawnTimer = 0;
    playerX = 170;

    keys.left = false;
    keys.right = false;

    player.style.left = playerX + "px";
    scoreText.innerText = "Score: 0";

    menu.style.display = "none";

    createRoad();

    running = true;

    gameLoop();
}

function moveRoad() {
    lines.forEach(line => {
        let top = parseFloat(line.style.top);

        top += speed;

        if (top > 600) {
            top = -120;
        }

        line.style.top = top + "px";
    });
}

function movePlayer() {
    if (keys.left) {
        playerX -= 7;
    }

    if (keys.right) {
        playerX += 7;
    }

    if (playerX < 65) {
        playerX = 65;
    }

    if (playerX > 280) {
        playerX = 280;
    }

    player.style.left = playerX + "px";
}

function checkCollision(enemy) {
    const playerRect = player.getBoundingClientRect();
    const enemyRect = enemy.element.getBoundingClientRect();

    return !(
        playerRect.right < enemyRect.left + 8 ||
        playerRect.left > enemyRect.right - 8 ||
        playerRect.bottom < enemyRect.top + 8 ||
        playerRect.top > enemyRect.bottom - 8
    );
}

function moveEnemies() {
    for (let i = enemies.length - 1; i >= 0; i--) {
        const enemy = enemies[i];

        enemy.y += speed;
        enemy.element.style.top = enemy.y + "px";

        if (checkCollision(enemy)) {
            gameOver();
            return;
        }

        if (enemy.y > 650) {
            enemy.element.remove();
            enemies.splice(i, 1);

            score += 10;
            scoreText.innerText = "Score: " + score;

            speed = Math.min(12, 5 + score / 100);
        }
    }
}

function gameOver() {
    running = false;

    message.innerText = "💥 GAME OVER! Score: " + score;

    menu.style.display = "block";

    menu.querySelector("button").innerText = "RESTART";
}

function gameLoop() {
    if (!running) return;

    moveRoad();
    movePlayer();
    moveEnemies();

    if (!running) return;

    spawnTimer++;

    if (spawnTimer > 90) {
        createEnemy();
        spawnTimer = 0;
    }

    animationId = requestAnimationFrame(gameLoop);
}

createRoad();
</script>

</body>
</html>
