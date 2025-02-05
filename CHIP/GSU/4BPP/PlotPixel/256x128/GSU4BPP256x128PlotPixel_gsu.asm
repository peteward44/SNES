// SNES GSU 4BPP 256x128 Plot Pixel Demo (GSU Code) by krom (Peter Lemon):
arch snes.gsu

GSUStart:
  sub r0 // R0 = 0
  cmode // Set Color Mode

  // Fill Screen With Clear Color
  sub r0 // R0 = 0 (Fill Value)
  iwt r3, #$0000 // R3 = Screen Base (SRAM Destination)
  iwt r12, #(256*128)/4 // R12 = Loop Count
  move r13, r15 // R13 = Loop Address
  // Loop:
    stw (r3) // Store Fill Value Word To Screen Base
    inc r3 // Screen Base++
    loop // IF (Loop Count != 0) Loop
    inc r3 // Screen Base++ (Delay Slot)

  // Plot Pixel Color At X/Y Location
  ibt r0, #1 // R0 = Color #1
  color // Set Value In COLOR
  ibt r1, #127 // R1 = Plot X Position
  ibt r2, #63 // R2 = Plot Y Position
  plot // Plot Color
  rpix // Flush Pixel Cache

  stop // Stop GSU
  nop // Delay Slot