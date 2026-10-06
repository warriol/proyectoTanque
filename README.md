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
* **Dificultad Progresiva por bajas:** Cada 8 enemigos eliminados, el máximo aumenta en 1 y el intervalo de aparición se reduce en 0.08 segundos.
* **Dificultad Progresiva por tiempo:** Cada 3 minutos de supervivencia, el máximo aumenta en 2 enemigos y el intervalo se reduce en 0.05 segundos. El intervalo mínimo actual es de 0.5 segundos.
* **Velocidad por tiempo:** Cada 3 minutos de supervivencia, la velocidad de movimiento de todos los robots y de los nuevos robots aumenta un 15%. Cada nivel usa un color diferente para comunicar visualmente el aumento de dificultad.

### 🛒 3.3. Tienda y Economía
* **Moneda:** Cada enemigo eliminado otorga 10 créditos.
* **Tienda en Tiempo Real:** Está disponible durante el combate y sus compras no pausan el juego.
* **Reparaciones:** Permiten recuperar una zona dañada del chasis o de la torreta, devolviéndola al estado visual verde.
* **Mejoras disponibles:**
  * **Blindaje:** Aumenta la cantidad de impactos que el tanque puede soportar.
  * **Cadencia:** Reduce el tiempo entre disparos.
  * **Giro de torreta:** Aumenta la velocidad de orientación de la torreta.
* **Precios:** Cada botón muestra su precio actual. Después de cada compra, el nivel de esa opción aumenta y su precio también.
* **Disponibilidad:** Un botón solo se habilita cuando el jugador tiene créditos suficientes; las reparaciones también requieren que la zona esté dañada.

### 🔊 3.4. Audio
* **Efectos:** Los disparos, explosiones, compras de mejoras y el motor del tanque se reproducen mediante `AudioManager` en el bus `SFX`.
* **Música:** `Target_Acquired.mp3` se reproduce en loop durante el menú y la partida mediante el bus `Music`.
* **Volumen:** El menú permite ajustar por separado los efectos y la música. Los valores por defecto están centralizados en `GameSettings`.

### 🌐 3.5. Localización
* **Textos globales:** Menú, HUD, tienda, récords y pantalla de derrota utilizan claves del autoload `Localization`.
* **Idiomas actuales:** Español e inglés.
* **Extensión futura:** Para añadir un idioma se agrega un nuevo diccionario de traducciones en `scripts/localization.gd`.

---

## 🖥️ 4. Interfaz de Usuario (UI/UX)

* **Zona Central / Arena:** Campo de batalla con límites definidos.
* **Panel de Estadísticas:** Muestra los valores actuales del tanque en tiempo real.
  * **Velocidad de ataque:** Muestra la cadencia actual de disparo del tanque, expresada como el tiempo entre proyectiles o disparos por segundo.
    * El valor debe actualizarse cuando la torreta recibe daño, mejoras de cadencia o reparaciones.
  * **Velocidad de movimiento:** Muestra la velocidad actual del tanque y permite identificar visualmente la penalización aplicada cuando una zona del chasis está dañada.
* **Panel de Tienda:** Botones de compra rápida de mejoras y reparaciones.
  * Se ubica en la zona inferior derecha para mantener las acciones accesibles durante el combate.
  * Incluye reparaciones para las cinco zonas y mejoras de blindaje, cadencia y giro de torreta.
* **Esquema de Estado del Tanque:** Diagrama que resalta visualmente los componentes dañados en rojo.
  * **Estado de daños:** Incluye una representación visual pequeña del tanque dividida en cinco zonas: lateral frontal, lateral trasero, lateral izquierdo, lateral derecho y torreta.
    * Cada zona aparece en **verde** cuando está intacta.
    * Cuando recibe su primer impacto, cambia a **rojo** para indicar que está dañada.
    * La representación debe reflejar inmediatamente cualquier reparación y volver a mostrar la zona en verde.
* **HUD Superior:** Contador de monedas y tiempo de supervivencia.
* **Panel de Partida:** Muestra el tiempo transcurrido, enemigos simultáneos, enemigos eliminados y nivel de dificultad.
* **Panel de Configuración:** Permite ajustar intervalo de aparición, velocidad enemiga, área de reacción del tanque, volumen de efectos y volumen de música. Incluye restauración de valores por defecto.

---

## 🛠️ 5. Especificaciones Técnicas (TDD)

* **Motor:** Godot Engine 4.x
* **Lenguaje:** GDScript

### 🧩 Estructura Principal de Nodos
* `Tank` (`CharacterBody2D`): Lógica de movimiento autónomo, apuntado y disparo.
* `MagnetRobot` (`CharacterBody2D`): Lógica de persecución magnética y respuesta a impulsos físicos.
* `Bullet` (`Area2D` / `RigidBody2D`): Proyectil con cálculo de empuje (*knockback*).
* `Spawner` (`Node2D`): Temporizador y gestor de generación de enemigos.
* `HUD` (`CanvasLayer`): Gestión de estadísticas, tienda, dificultad y actualización visual de eventos.
* `RecordManager` (`Node` autoload): Persistencia local del top 10 y punto de integración futura con Steam.
* `AudioManager` (`Node` autoload): Reproducción de efectos y música mediante buses de audio.
* `Localization` (`Node` autoload): Diccionario global de textos traducibles.

---

## 📁 6. Estructura de Archivos

Este es el árbol principal de `res://`. Los archivos `.uid` son generados por Godot para identificar scripts y no deben editarse manualmente.

```text
proyecto-tanque/
├── project.godot
├── icon.svg
├── scenes/
│   ├── main_menu.tscn
│   ├── main_arena.tscn
│   ├── tank.tscn
│   ├── robot.tscn
│   └── bullet.tscn
├── scripts/
│   ├── game_settings.gd
│   ├── localization.gd
│   ├── audio_manager.gd
│   ├── main_menu.gd
│   ├── main_arena.gd
│   ├── tank.gd
│   ├── robot.gd
│   ├── bullet.gd
│   ├── spawner.gd
│   ├── hud.gd
│   └── record_manager.gd
├── ui/
│   └── hud.tscn
└── audio/
  └── sfx/
    ├── bullet_shoot.wav
    ├── robot_explosion.wav
    ├── tank_engine.wav
    ├── game_over.wav
    ├── compra_tienda_mejora.wav
    └── Target_Acquired.mp3
```

### 📄 Archivos de configuración y arranque

* **`project.godot`:** Configuración general del proyecto. Define el nombre, la resolución, la escena inicial y los autoloads `GameSettings`, `RecordManager`, `Localization` y `AudioManager`. Normalmente no se usa para balancear enemigos o tanque.
* **`scripts/game_settings.gd`:** Fuente central de valores por defecto y reglas compartidas. Aquí se modifican el intervalo inicial de aparición, velocidad de enemigos, radio de detección, volúmenes, progresión de dificultad, recompensa, precios de tienda y nivel máximo de mejoras. También contiene `reset_defaults()` y `get_difficulty_name()`.
* **`scripts/audio_manager.gd`:** Crea los buses `SFX` y `Music`, reproduce `Target_Acquired.mp3` en loop y ofrece funciones para ajustar el volumen de cada bus.
* **`scripts/localization.gd`:** Contiene las claves de texto traducibles y los idiomas disponibles.
* **`scripts/main_menu.gd`:** Controla los botones `JUGAR`, `CONFIGURACIÓN` y `RECORDS`. Lee y actualiza los sliders de `GameSettings`. Aquí se cambia el comportamiento del menú, no el diseño visual.
* **`scenes/main_menu.tscn`:** Diseño visual del menú, botones, panel opaco de configuración y tabla de récords. Para cambiar posiciones, tamaños o textos iniciales se edita esta escena; los valores de los sliders se cargan después desde `GameSettings`.

### 🎮 Archivos de la partida

* **`scripts/main_arena.gd`:** Orquesta una partida. Conecta tanque, spawner y HUD, entrega la configuración global, cuenta tiempo/créditos, gestiona la tienda y crea la pantalla de `GAME OVER` con el puntaje.
* **`scenes/main_arena.tscn`:** Escena que reúne arena, paredes, tanque, spawner y HUD. Aquí se modifica la composición de la partida y las colisiones de los límites.
* **`scripts/tank.gd`:** Cerebro del tanque autónomo. Controla detección, apuntado, movimiento, disparo, impactos, reparaciones y mejoras. Las estadísticas iniciales se leen desde `GameSettings`; las compras modifican el estado durante la partida.
* **`scenes/tank.tscn`:** Nodos físicos y visuales del tanque: chasis, torreta, muzzle, temporizador, área de detección y cinco zonas de daño. Aquí se modifica la forma o posición de las colisiones, no los valores de balance.
* **`scripts/spawner.gd`:** Genera robots y controla la dificultad. Calcula el intervalo y el máximo de enemigos usando las variables inicializadas desde `GameSettings`. Aquí se modifica el algoritmo de aparición, no los valores por defecto.
* **`scripts/robot.gd`:** Comportamiento individual del enemigo: perseguir al tanque, cambiar velocidad/color por nivel y desaparecer al recibir un proyectil.
* **`scenes/robot.tscn`:** Forma, colisión y aspecto visual de cada robot.
* **`scripts/bullet.gd`:** Movimiento del proyectil, detección de impacto, destrucción del robot y notificación de la recompensa.
* **`scenes/bullet.tscn`:** Colisión y representación visual del proyectil.

### 🖥️ Archivos de interfaz y récords

* **`scripts/hud.gd`:** Actualiza en tiempo real estadísticas, tienda, créditos, niveles de mejora, enemigos activos, tiempo, dificultad y colores de daño. Los textos dinámicos de los botones se definen aquí; editar solo el `text` de un botón en `hud.tscn` no basta porque este script lo reemplaza durante la partida.
* **`ui/hud.tscn`:** Diseño visual del HUD: estadísticas, panel de partida y tienda inferior derecha. Aquí se modifican posiciones, tamaños, columnas y fuente de los controles.
* **`scripts/record_manager.gd`:** Guarda y carga el top 10 local en `user://records.json`. Ordena los puntajes y decide si una partida entra en la tabla. La función `submit_to_steam()` es el punto reservado para integrar posteriormente `Steam.uploadLeaderboardScore()`.
* **`audio/sfx/`:** Archivos de sonido importados por Godot. Las licencias de los recursos deben revisarse antes de publicar el juego en Steam.

### 🧭 Guía rápida de modificación

* **Cambiar valores por defecto:** editar `scripts/game_settings.gd`.
* **Cambiar rangos de los sliders:** editar `scenes/main_menu.tscn`; actualizar también las constantes `MIN_*` y `MAX_*` de `game_settings.gd`.
* **Cambiar el algoritmo de dificultad:** editar `scripts/spawner.gd`.
* **Cambiar la velocidad o cadencia inicial del tanque:** editar las constantes correspondientes en `game_settings.gd`.
* **Cambiar la forma de las colisiones:** editar `scenes/tank.tscn`.
* **Cambiar textos dinámicos del HUD o la tienda:** editar `scripts/hud.gd`.
* **Cambiar textos del juego o traducirlo:** editar `scripts/localization.gd`.
* **Cambiar música y efectos:** editar `scripts/audio_manager.gd` y los recursos dentro de `audio/sfx/`.
* **Cambiar el volumen inicial:** editar `DEFAULT_SFX_VOLUME` y `DEFAULT_MUSIC_VOLUME` en `scripts/game_settings.gd`.
* **Cambiar el cálculo del puntaje:** editar `_calculate_score()` en `scripts/main_arena.gd`.
* **Cambiar los datos guardados de récord:** editar la creación del diccionario en `_save_current_record()` y la persistencia en `scripts/record_manager.gd`.
* **Cambiar la integración futura con Steam:** implementar `submit_to_steam()` en `scripts/record_manager.gd`, manteniendo la tabla local como respaldo.

> **Regla de aprendizaje:** primero busca quién es dueño del dato. Los valores de balance pertenecen a `GameSettings`, el comportamiento pertenece a los scripts y la apariencia pertenece a las escenas `.tscn`. Evitar duplicar un mismo valor en ambos lugares previene que el Inspector o una escena sobrescriban silenciosamente la configuración global.

---

## 🚀 7. Plan de Desarrollo (MVP)

1. [x] **Fase 1:** Prototipo básico con figuras geométricas (físicas de empuje, movimiento y spawner de robots).
2. [x] **Fase 2:** Integración de la interfaz gráfica (UI) y ajuste de controles/HUD.
3. [x] **Fase 3:** Implementación del sistema de daño localizado y lógica de la tienda.
4. [x] **Fase 4:** Ajuste de balanceo y efectos de sonido.
5. [ ] **Fase 5:** Implementación del arte retro: sprites definitivos, animaciones, efectos visuales y dirección artística.
