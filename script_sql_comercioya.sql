
PRAGMA foreign_keys = ON;

-- =========================================================
-- PROYECTO MÓDULO 7 (consigna módulo 6 SQL)
-- Sistema de Gestión de Ventas - Comercio Ya
-- Base relacional: clientes, productos, ventas
-- =========================================================

-- LIMPIEZA INICIAL
DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

-- =========================================================
-- LECCIÓN 1: Base de datos relacional
-- =========================================================
-- Una base de datos relacional organiza información en tablas
-- conectadas entre sí mediante claves primarias y foráneas.
-- En este caso, el sistema permite registrar clientes, productos
-- y ventas de forma ordenada y confiable.

-- =========================================================
-- LECCIÓN 2: Consultas a una sola tabla
-- =========================================================
CREATE TABLE clientes (
    id_cliente INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL,
    apellido TEXT NOT NULL,
    ciudad TEXT NOT NULL,
    email TEXT UNIQUE,
    telefono TEXT
);

INSERT INTO clientes (id_cliente, nombre, apellido, ciudad, email, telefono) VALUES
(1, 'Camila', 'Rojas', 'Santiago', 'camila.rojas@email.com', '+56911111111'),
(2, 'Javier', 'Muñoz', 'Valparaíso', 'javier.munoz@email.com', '+56922222222'),
(3, 'Fernanda', 'Soto', 'Concepción', 'fernanda.soto@email.com', '+56933333333'),
(4, 'Matías', 'Pérez', 'Santiago', 'matias.perez@email.com', '+56944444444'),
(5, 'Daniela', 'Araya', 'La Serena', 'daniela.araya@email.com', '+56955555555');

-- Consulta 1: todos los clientes
SELECT * FROM clientes;

-- Consulta 2: clientes de Santiago
SELECT * FROM clientes
WHERE ciudad = 'Santiago';

-- Consulta 3: búsqueda por nombre
SELECT * FROM clientes
WHERE nombre LIKE 'Ca%';

-- =========================================================
-- LECCIÓN 3: Tablas relacionadas
-- =========================================================
CREATE TABLE productos (
    id_producto INTEGER PRIMARY KEY,
    nombre_producto TEXT NOT NULL,
    categoria TEXT NOT NULL,
    precio REAL NOT NULL CHECK (precio > 0)
);

INSERT INTO productos (id_producto, nombre_producto, categoria, precio) VALUES
(1, 'Notebook Lenovo IdeaPad', 'Tecnología', 549990),
(2, 'Mouse Logitech M185', 'Accesorios', 12990),
(3, 'Teclado Redragon Kumara', 'Accesorios', 34990),
(4, 'Monitor Samsung 24"', 'Tecnología', 149990),
(5, 'Impresora HP DeskJet', 'Oficina', 89990),
(6, 'Webcam Full HD', 'Tecnología', 39990),
(7, 'Adaptador VGA', 'Obsoleto', 6990);

CREATE TABLE ventas (
    id_venta INTEGER PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    fecha_venta TEXT NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    total REAL NOT NULL CHECK (total >= 0),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

INSERT INTO ventas (id_venta, id_cliente, id_producto, fecha_venta, cantidad, total) VALUES
(1, 1, 1, '2026-02-01', 1, 549990),
(2, 1, 2, '2026-02-01', 2, 25980),
(3, 2, 4, '2026-02-03', 1, 149990),
(4, 3, 3, '2026-02-05', 1, 34990),
(5, 4, 2, '2026-02-06', 1, 12990),
(6, 4, 6, '2026-02-06', 1, 39990),
(7, 5, 5, '2026-02-08', 1, 89990),
(8, 2, 2, '2026-02-10', 1, 12990),
(9, 3, 4, '2026-02-11', 1, 149990),
(10, 1, 6, '2026-02-12', 1, 39990);

-- JOIN: qué cliente compró qué producto y cuándo
SELECT
    v.id_venta,
    c.nombre || ' ' || c.apellido AS cliente,
    p.nombre_producto AS producto,
    v.fecha_venta,
    v.cantidad,
    v.total
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN productos p ON v.id_producto = p.id_producto
ORDER BY v.fecha_venta;

-- =========================================================
-- LECCIÓN 4: Consultas agrupadas
-- =========================================================

-- Total general vendido
SELECT SUM(total) AS total_general_ventas
FROM ventas;

-- Promedio de venta
SELECT ROUND(AVG(total), 2) AS promedio_venta
FROM ventas;

-- Cantidad de ventas registradas
SELECT COUNT(*) AS cantidad_ventas
FROM ventas;

-- Ventas agrupadas por cliente
SELECT
    c.nombre || ' ' || c.apellido AS cliente,
    COUNT(v.id_venta) AS numero_compras,
    SUM(v.total) AS total_gastado
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
GROUP BY c.id_cliente
ORDER BY total_gastado DESC;

-- Ventas agrupadas por producto
SELECT
    p.nombre_producto,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.total) AS ingreso_total
FROM ventas v
JOIN productos p ON v.id_producto = p.id_producto
GROUP BY p.id_producto
ORDER BY unidades_vendidas DESC, ingreso_total DESC;

-- =========================================================
-- LECCIÓN 5: Consultas anidadas
-- =========================================================

-- Clientes que hicieron más de una compra
SELECT nombre, apellido, ciudad
FROM clientes
WHERE id_cliente IN (
    SELECT id_cliente
    FROM ventas
    GROUP BY id_cliente
    HAVING COUNT(*) > 1
);

-- Producto más vendido
SELECT nombre_producto
FROM productos
WHERE id_producto = (
    SELECT id_producto
    FROM ventas
    GROUP BY id_producto
    ORDER BY SUM(cantidad) DESC, SUM(total) DESC
    LIMIT 1
);

-- Cliente que más gastó
SELECT nombre, apellido
FROM clientes
WHERE id_cliente = (
    SELECT id_cliente
    FROM ventas
    GROUP BY id_cliente
    ORDER BY SUM(total) DESC
    LIMIT 1
);

-- =========================================================
-- LECCIÓN 6: Creación y manipulación de tablas
-- =========================================================

-- Agregar columna stock a productos
ALTER TABLE productos ADD COLUMN stock INTEGER DEFAULT 0;

-- Cargar stock inicial
UPDATE productos SET stock = 8  WHERE id_producto = 1;
UPDATE productos SET stock = 25 WHERE id_producto = 2;
UPDATE productos SET stock = 12 WHERE id_producto = 3;
UPDATE productos SET stock = 10 WHERE id_producto = 4;
UPDATE productos SET stock = 6  WHERE id_producto = 5;
UPDATE productos SET stock = 15 WHERE id_producto = 6;
UPDATE productos SET stock = 4  WHERE id_producto = 7;

-- Verificar stock inicial
SELECT id_producto, nombre_producto, stock
FROM productos
ORDER BY id_producto;

-- Registrar una nueva venta y actualizar stock
INSERT INTO ventas (id_venta, id_cliente, id_producto, fecha_venta, cantidad, total)
VALUES (11, 5, 2, '2026-02-13', 3, 38970);

UPDATE productos
SET stock = stock - 3
WHERE id_producto = 2;

-- Verificar stock actualizado del producto vendido
SELECT id_producto, nombre_producto, stock
FROM productos
WHERE id_producto = 2;

-- Eliminar producto obsoleto sin ventas asociadas
DELETE FROM productos
WHERE id_producto = 7;

-- Verificar catálogo final
SELECT id_producto, nombre_producto, categoria, precio, stock
FROM productos
ORDER BY id_producto;

-- Impacto documentado:
-- Se eliminó el producto "Adaptador VGA" porque no registraba ventas
-- y estaba marcado como obsoleto. No hubo impacto sobre la tabla ventas
-- ya que no existían transacciones relacionadas con ese producto.

-- =========================================================
-- CONSULTAS FINALES DE APOYO
-- =========================================================

-- Resumen final de ventas por cliente
SELECT
    c.nombre || ' ' || c.apellido AS cliente,
    COUNT(v.id_venta) AS compras,
    SUM(v.total) AS total_comprado
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente
ORDER BY total_comprado DESC;

-- Resumen final de productos vendidos
SELECT
    p.nombre_producto,
    COALESCE(SUM(v.cantidad), 0) AS unidades_vendidas,
    COALESCE(SUM(v.total), 0) AS ventas_generadas,
    p.stock AS stock_actual
FROM productos p
LEFT JOIN ventas v ON p.id_producto = v.id_producto
GROUP BY p.id_producto
ORDER BY ventas_generadas DESC, unidades_vendidas DESC;
