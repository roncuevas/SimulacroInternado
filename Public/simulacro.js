let boleta = "";
let selectedSpotId = null;

const statusElement = document.getElementById("status");
const globalPositionElement = document.getElementById("global_position");
const positionElement = document.getElementById("position");
const spotsElement = document.getElementById("spots");
const confirmationDiv = document.getElementById("confirmation");

function login() {
    boleta = prompt("Ingresa tu boleta:");
    const ws = new WebSocket(`ws://localhost:8080/queue?boleta=${boleta}`);

    ws.onmessage = ({ data }) => {
        const { error, globalPosition, studentsCount, actualPosition, remaining, spots } = JSON.parse(data);

        if (error) {
            updateStatus(error);
            return;
        }

        globalPositionElement.innerText = `Eres el lugar: ${globalPosition} de ${studentsCount}`;
        positionElement.innerText = `Tu turno actual es: ${actualPosition} y faltan ${remaining}`;
        renderSpots(spots);

        updateStatus(
            actualPosition === 1 ? "Es tu turno, selecciona una plaza." : "Esperando turno..."
        );
    };
}

function renderSpots(spots) {
    const items = spots.map(spot =>
        `<li>${spot.name} - ${spot.location}${
            spot.id ? ` <button onclick="selectSpot('${spot.id}', '${spot.name}', '${spot.location}')">Seleccionar</button>` : ""
        }</li>`
    ).join("");

    spotsElement.innerHTML = `
        <h2>Plazas Disponibles</h2>
        <ul>${items}</ul>
        <div id="confirmation" style="margin-top: 20px;"></div>
    `;
}

function selectSpot(id, name, location) {
    selectedSpotId = id;
    confirmationDiv.innerHTML = `
        <p>Has seleccionado: <strong>${name} - ${location}</strong></p>
        <button onclick="confirmSelection()">Confirmar Envío</button>
    `;
}

async function confirmSelection() {
    if (!selectedSpotId || !confirm("¿Estás seguro de que deseas seleccionar esta plaza?")) return;

    try {
        const res = await fetch(`/select/${selectedSpotId}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ boleta })
        });

        if (!res.ok) throw new Error();

        updateStatus("Plaza seleccionada exitosamente.");
        setVisibility(false);
        alert("Plaza seleccionada exitosamente.");
    } catch {
        alert("Error: La plaza ya fue ocupada.");
    }
}

function updateStatus(message) {
    statusElement.innerText = message;
}

function setVisibility(visible) {
    const visibility = visible ? "visible" : "hidden";
    [spotsElement, positionElement, globalPositionElement].forEach(el => {
        el.style.visibility = visibility;
    });
}
