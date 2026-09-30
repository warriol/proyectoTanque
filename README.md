# 🛡️ Tank Overdrive: Auto-Defender (Nombre Provisional)

> **Documentación del Proyecto (GDD / TDD)**  
> *Juego Indie de gestión en tiempo real, supervivencia y combate autónomo.*

---

## 📌 1. Visión General del Proyecto

* **Nombre Provisional:** Tank Overdrive: Auto-Defender
* **Género:** Rogue-lite / Gestión en tiempo real / Acción automática (*Autoplay*).
* **Plataforma Objetivo:** PC / Web (vía Godot Engine).
* **Perspectiva Visual:** Cenital (vista superior) / Ortogonal.
* **Premisa:** El jugador no controla directamente el movimiento ni los disparos del tanque, sino que gestiona su supervivencia en tiempo real comprando mejoras y efectuando reparaciones mientras el tanque combate automáticamente en una arena infestada de robots magnéticos.

### 📜 Lore / Trasfondo
> *(Sección pendiente de definir)*  
> *Notas iniciales: Contexto retro-futurista donde una unidad acorazada autónoma debe resistir hordas de autómatas magnéticos descontrolados.*

---

## 🔄 2. Ciclo Principal de Juego (*Core Loop*)

1. **Combate Autónomo:** El tanque se desplaza y dispara de forma automática dentro de los límites de la arena.
2. **Generación de Recursos:** Cada robot destruido o empujado fuera de los límites otorga monedas al jugador.
3. **Gestión en Tiempo Real:** El jugador administra una tienda en vivo para adquirir mejoras y reparar daños sin pausar el juego.
4. **Escalado y Derrota:** La densidad y velocidad de los enemigos aumenta progresivamente hasta que el tanque es destruido, buscando superar el récord de tiempo de supervivencia.

---

## ⚙️ 3. Mecánicas y Sistemas

### 🚜 3.1. El Tanque
* **Movimiento y Apuntado:** Controlados totalmente por el sistema/IA.
* **Sistema de Daño Localizado:**
  * **Chasis / Ruedas:** Los impactos reducen la velocidad de desplazamiento y la capacidad de giro.
  * **Torreta:** Los impactos reducen la velocidad de rotación o la cadencia de disparo.
* **Atributos / Estadísticas:**
  * Velocidad y giro del chasis.
  * Rotación y cadencia de la torreta.
  * Fuerza de empuje del proyectil (*Knockback*).
  * Nivel de armadura y estado de reparación.

### 🤖 3.2. Enemigos (Robots Imán)
* **Comportamiento:** Aparecen de forma aleatoria en los bordes de la arena y son atraídos magnéticamente en línea recta hacia la posición actual del tanque.
* **Física de Impacto:** Reciben fuerza de empuje al ser impactados. Si salen de la arena, se destruyen.
* **Dificultad Progresiva:** Su velocidad y tasa de aparición (*spawn rate*) incrementan de forma continua a lo largo del tiempo.

### 🛒 3.3. Tienda y Economía
* **Moneda:** Recompensa obtenida por cada enemigo eliminado.
* **Opciones de Compra en Tiempo Real:**
  * **Mejoras:** Aumento de velocidad, potencia de tiro, velocidad de torreta, armadura.
  * **Reparaciones:** Arreglo específico de componentes dañados (ejes, torreta, etc.).

---

## 🖥️ 4. Interfaz de Usuario (UI/UX)

* **Zona Central / Arena:** Campo de batalla con límites definidos.
* **Panel de Estadísticas:** Muestra los valores actuales del tanque en tiempo real.
* **Panel de Tienda:** Botones de compra rápida de mejoras y reparaciones.
* **Esquema de Estado del Tanque:** Diagrama que resalta visualmente los componentes dañados en rojo.
* **HUD Superior:** Contador de monedas y tiempo de supervivencia.

---

## 🛠️ 5. Especificaciones Técnicas (TDD)

* **Motor:** Godot Engine 4.x
* **Lenguaje:** GDScript

### 🧩 Estructura Principal de Nodos
* `Tank` (`CharacterBody2D`): Lógica de movimiento autónomo, apuntado y disparo.
* `MagnetRobot` (`CharacterBody2D`): Lógica de persecución magnética y respuesta a impulsos físicos.
* `Bullet` (`Area2D` / `RigidBody2D`): Proyectil con cálculo de empuje (*knockback*).
* `Spawner` (`Node2D`): Temporizador y gestor de generación de enemigos.
* `UIManager` (`Control`): Gestión de paneles, tienda y actualización de eventos.

---

## 🚀 6. Plan de Desarrollo (MVP)

1. [ ] **Fase 1:** Prototipo básico con figuras geométricas (físicas de empuje, movimiento y spawner de robots).
2. [ ] **Fase 2:** Implementación del sistema de daño localizado y lógica de la tienda.
3. [ ] **Fase 3:** Integración de la interfaz gráfica (UI) y ajuste de controles/HUD.
4. [ ] **Fase 4:** Ajuste de balanceo, arte retro y efectos de sonido.
