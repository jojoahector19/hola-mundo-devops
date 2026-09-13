-- Tabla que registra cada visita/peticion al API
-- El campo "environment" indica si la peticion se sirvio en 'develop' o 'release'
CREATE TABLE IF NOT EXISTS visits (
    id           SERIAL PRIMARY KEY,
    created_at   TIMESTAMP NOT NULL DEFAULT now(),
    environment  VARCHAR(20) NOT NULL CHECK (environment IN ('develop', 'release'))
);
