Output demo.gif

Set FontSize 14
Set Width 1100
Set Height 620
Set Padding 24
Set Theme "Catppuccin Mocha"
Set WindowBar Colorful
Set TypingSpeed 40ms

Hide
Type "export PATH=$PWD:$PATH"
Enter
Type "clear"
Enter
Show

Sleep 800ms
Type "# 1. Inspect Apple Silicon ANE & Foundation Models status"
Sleep 400ms
Enter
Type "swiftvector status"
Sleep 400ms
Enter
Sleep 2.5s

Type "# 2. Extract AST chunks & compute on-device embeddings"
Sleep 400ms
Enter
Type "swiftvector index Sources/"
Sleep 400ms
Enter
Sleep 3s

Type "# 3. Run sub-3ms Accelerate SIMD vector search"
Sleep 400ms
Enter
Type 'swiftvector search "Accelerate SIMD cosine distance" --limit 3'
Sleep 400ms
Enter
Sleep 3.5s

Type "# 4. Explain symbol logic using Apple Foundation Models"
Sleep 400ms
Enter
Type "swiftvector explain AccelerateSIMDDistance"
Sleep 400ms
Enter
Sleep 4s
