'use strict';
const token = location.hash.slice(1);
history.replaceState(null, '', location.pathname);
const form = document.querySelector('#form');
const status = document.querySelector('#status');
const output = document.querySelector('#output');
const button = document.querySelector('#run');
const connection = document.querySelector('#connection');
async function checkConnection() {
  if (!token) {
    connection.textContent = 'Falta el token: abre el enlace completo que muestra la computadora.';
    return;
  }
  try {
    const response = await fetch('/connected', {method: 'POST', headers: {'Content-Type': 'application/json', 'X-Local-Token': token}, body: '{}'});
    if (!response.ok) throw new Error();
    const result = await response.json();
    connection.textContent = result.remote ? 'Conectado a la computadora. Ya puedes pegar el enlace de Delta.' : 'Conectado desde esta computadora. Para comprobar el iPhone, abre allí el enlace completo.';
  } catch (_) {
    connection.textContent = 'No se pudo comprobar la conexión. Mantén abierto el programa y vuelve a abrir el enlace completo.';
  }
}
checkConnection();
form.addEventListener('submit', async (event) => {
  event.preventDefault();
  output.hidden = true;
  document.querySelector('#key').value = '';
  button.disabled = true;
  status.textContent = 'Intentando obtener la key…';
  try {
    if (!token) throw new Error('Falta el token del enlace local. Abre el enlace completo que muestra Python.');
    const response = await fetch('/solve', {method: 'POST', headers: {'Content-Type': 'application/json', 'X-Local-Token': token}, body: JSON.stringify({url: document.querySelector('#url').value.trim()})});
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || 'Error desconocido.');
    document.querySelector('#key').value = result.key;
    output.hidden = false;
    status.textContent = 'Key recibida. Pruébala en Delta; no está verificada.';
  } catch (error) { status.textContent = error.message || 'Error de conexión.'; }
  finally { button.disabled = false; }
});
document.querySelector('#copy').addEventListener('click', async () => {
  const key = document.querySelector('#key');
  try { await navigator.clipboard.writeText(key.value); status.textContent = 'Key copiada.'; }
  catch (_) { key.focus(); key.select(); status.textContent = 'Selecciona y copia la key manualmente.'; }
});
