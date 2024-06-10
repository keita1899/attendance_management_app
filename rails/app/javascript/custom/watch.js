function displayTime() {

  function padZero(value) {
    return value.toString().padStart(2, '0');
  }

  const now = new Date();

  const hour = padZero(now.getHours());
  const minute = padZero(now.getMinutes());
  const second = padZero(now.getSeconds());

  const currentTime = `${hour}:${minute}:${second}`;
  document.querySelector('.clock').textContent = currentTime; 
}

displayTime();
setInterval(displayTime, 1000);