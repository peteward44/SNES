// SNES GSU 4BPP 256x160 Plot Line Demo (GSU Code) by krom (Peter Lemon):
arch snes.gsu

GSUStart:
  sub r0 // R0 = 0
  cmode // Set Color Mode

  // Fill Screen With Clear Color
  sub r0 // R0 = 0 (Fill Value)
  iwt r3, #$0000 // R3 = Screen Base (SRAM Destination)
  iwt r12, #(256*160)/4 // R12 = Loop Count
  move r13, r15 // R13 = Loop Address
  // Loop:
    stw (r3) // Store Fill Value Word To Screen Base
    inc r3 // Screen Base++
    loop // IF (Loop Count != 0) Loop
    inc r3 // Screen Base++ (Delay Slot)

  // Plot Line Color From X0/Y0 To X1/Y1 Location
  ibt r0, #1 // R0 = Color #1
  color // Set Value In COLOR

  iwt r1, #0 // R1 = X0
  iwt r2, #0 // R2 = Y0
  iwt r3, #255 // R3 = X1
  iwt r4, #159 // R4 = Y1

  with r5 ; sub r5 // R5 = 0
  with r3 ; sub r1 // R3 = DX (X1 - X0)
  bpl SXPos
  inc r5 // IF (X1 > X0), R5 (SX) = 1 (Delay Slot)
  dec r5 // IF (X1 < X0), R5 (SX) = -1
  dec r5 // R5 = -1
  with r3 ; not // R3 ~= R3
  inc r3 // R3 = ABS(DX)
  SXPos:

  with r6 ; sub r6 // R6 = 0
  with r4 ; sub r2 // R4 = DY (Y1 - Y0)
  bpl SYPos
  inc r6 // IF (Y1 > Y0), R6 (SY) = 1 (Delay Slot)
  dec r6 // IF (Y1 < Y0), R6 (SY) = -1
  dec r6 // R6 = -1
  with r4 ; not // R4 ~= R4
  inc r4 // R4 = ABS(DY)
  SYPos:

  from r3 ; cmp r4 // Compare DX To DY
  blt YMajor // IF (DX < DY) Y Major, Else X Major
  plot // Plot Color (R1++) (Delay Slot)

  from r3 ; lsr // IF (DX >= DY), R0 (X Error) = R3 (DX) / 2 (X Error = DX / 2)
  move r12, r3 // R12 = Loop Count (DX)
  move r13, r15 // R13 = Loop Address
  // LoopX:
    sub r4 // Subtract R4 (DY) From R0 (X Error) & Compare R4 (X Error) To Zero (X Error -= DY)
    bge XEnd
    dec r1 // R1-- (Delay Slot)
    with r2 ; add r6 // IF (X Error < 0), Add R6 (SY) To R2 (Y0) (Y0 += SY)
    add r3 // IF (X Error < 0), Add R3 (DX) To R0 (X Error) (X Error += DX)
    XEnd:
      with r1 ; add r5 // Add R5 (SX) To R1 (X0) (X0 += SX)
      loop // LoopX, IF (X0 == X1), Line End
      plot // Plot Color (R1++) (Delay Slot)
      bra LineEnd

  YMajor:
  from r4 ; lsr // IF (DX < DY), R0 (Y Error) = R4 (DY) / 2 (Y Error = DY / 2)
  move r12, r4 // R12 = Loop Count (DY)
  move r13, r15 // R13 = Loop Address
  // LoopY:
    sub r3 // Subtract R3 (DX) From R0 (Y Error) & Compare R1 (Y Error) To Zero
    bge YEnd
    dec r1 // R1-- (Delay Slot)
    with r1 ; add r5 // IF (Y Error < 0), Add R5 (SX) To R1 (X0) (X0 += SX)
    add r4 // IF (Y Error < 0), Add R4 (DY) To R0 (Y Error) (Y Error += DY)
    YEnd:
      with r2 ; add r6 // Add R6 (SY) To R2 (Y0) (Y0 += SY)
      loop // LoopY, IF (Y0 == Y1), Line End
      plot // Plot Color (R1++) (Delay Slot)

  LineEnd:
    rpix // Flush Pixel Cache

  stop // Stop GSU
  nop // Delay Slot