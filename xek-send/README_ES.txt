XEK SEND — automatización GitHub Actions v1.3
Objetivo: Xperia Z5 Dual sumire_dsds / E6633, LineageOS 18.1, kernel 3.10.108.

CONTENIDO
- .github/workflows/xek-send-build.yml: compilación manual automatizada.
- xek-send/patches/0001-sumire-send-id-match.patch: conserva el cambio SEND ID 222 -> 492 kΩ.
- xek-send/patches/0002-fg-compare-full-profile.patch: conserva comparación completa de 128 bytes.
- xek-send/build.sh: valida, aplica, configura y compila.

CÓMO ACTIVARLO DESDE ANDROID
1. Abre tu fork de Professor-Berni/android_kernel_sony_msm8994 en GitHub.
2. Cambia a la rama lineage-18.1 (o crea tu propia rama basada en ella).
3. Sube la carpeta .github/workflows y la carpeta xek-send de este paquete a la raíz del repositorio. No reemplaces archivos existentes.
4. Abre la pestaña Actions -> XEK SEND Kernel Build -> Run workflow.
5. El workflow pide confirmar el valor histórico de RESISTANCE_ID. Selecciona "yes_491960_ohm" SOLO si has vuelto a medirlo y permanece alrededor de 491960 ohmios. Si no, selecciona "no" y la ejecución se detendrá antes de compilar.
6. Al terminar, abre el run y descarga el artefacto XEK-SEND-Image-gz-dtb.

QUÉ COMPILA
- Kernel arm64 con kitakami_sumire_defconfig.
- Image.gz-dtb con los DTB integrados que habilita el defconfig.
- Guarda .config, System.map, diff aplicado y SHA-256 como trazabilidad.

IMPORTANTE
- Los dos parches se prueban con --dry-run antes de aplicarse; cualquier conflicto detiene el workflow.
- El parche ID solo es válido si la batería es realmente Sony 1294-1249 y el RESISTANCE_ID medido, estable y en ohmios coincide aproximadamente con 491960. El dato histórico no prueba por sí solo la lectura actual.
- No cambia voltajes, cutoff, límites de corriente, Rslow ni protecciones.
- Esto NO produce boot.img ni ZIP instalable TWRP. Image.gz-dtb debe integrarse en el boot image correcto usando el ramdisk y los parámetros de arranque exactos del dispositivo. No flashees el artefacto directamente como boot.img.
- No afirma que SEND esté activo: tras arrancar se debe verificar el battery-type/perfil cargado y los logs del BMS.
- Conserva una copia del boot original y un método de recuperación antes de cualquier prueba.
