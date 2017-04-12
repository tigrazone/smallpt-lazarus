# smallpt-lazarus
This is a Lazarus Pascal version of well-known 99-lines-of-code c++ path tracer smallpt by Kevin Beason http://www.kevinbeason.com/smallpt/

Turbo Pascal 3/Lazarus port originally writen by Dirk de la Hunt http://www.iwasdeportedandalligotwasthislousydomain.co.uk/static.php?page=smallpt_tp

My version are little optimized - precalculated values, arithmetic simplifications, remove normalization if it not needed.
15% of speedups

Original version 1024x768 at 16 spp with 4 threads 68s
My version 59s

Compiling to x86_64 platform gives more speed!
I compared with MinGW gcc c++ version - it completed in 48s - 15% faster then compiled by Lazarus, but compared with Visual Studio Compiler(69s) or Intel C++ compiler result must be an approximately similar
