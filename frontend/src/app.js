// Llama al backend a traves del proxy /api (definido en nginx.conf)
fetch('/api/hello')
  .then((res) => res.json())
  .then((data) => {
    document.getElementById('message').innerText = data.message;
    document.getElementById('visits').innerText = data.visits;
    document.getElementById('environment').innerText = data.environment;
  })
  .catch((err) => {
    document.getElementById('message').innerText = 'Error al conectar con el API';
    console.error(err);
  });
