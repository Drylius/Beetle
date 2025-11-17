import 'package:flutter/material.dart';

class ImageBackgroundButton extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback onPressed;

  const ImageBackgroundButton({
    super.key,
    required this.imagePath,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveImagePath = imagePath; 

    return Card(
      elevation: 8, // Tambahkan sedikit bayangan
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onPressed, // Inilah fungsi klik tombol
        splashColor: Colors.white.withOpacity(0.3), // Efek klik warna putih transparan
        borderRadius: BorderRadius.circular(15),

        child: Container(
          width: 300,
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            // 1. Terapkan gambar sebagai dekorasi Container
            image: DecorationImage(
              // Menggunakan effectiveImagePath yang berasal dari constructor
              image: AssetImage(effectiveImagePath),
              fit: BoxFit.cover, // Gambar akan mencakup seluruh area Container
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4), // 2. Tambahkan overlay gelap (opacity 40%)
                BlendMode.darken,
              ),
            ),
          ),
          
          // 3. Teks diletakkan di tengah Container
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
