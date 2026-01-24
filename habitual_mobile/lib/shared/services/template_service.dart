import '../models/habit_template.dart';

class TemplateService {
  static List<HabitTemplate> getDefaultTemplates() {
    return [
      // Kesehatan
      const HabitTemplate(
        title: 'Minum Air 8 Gelas',
        description: 'Minum minimal 8 gelas air putih setiap hari untuk menjaga hidrasi tubuh',
        category: 'Kesehatan',
        icon: 'local_drink',
        color: 0xFF2196F3,
        tags: ['hidrasi', 'kesehatan', 'mudah'],
        difficulty: 'easy',
      ),
      const HabitTemplate(
        title: 'Minum Vitamin',
        description: 'Konsumsi vitamin harian untuk menjaga daya tahan tubuh',
        category: 'Kesehatan',
        icon: 'medication',
        color: 0xFF4CAF50,
        tags: ['vitamin', 'kesehatan', 'imunitas'],
        difficulty: 'easy',
      ),
      const HabitTemplate(
        title: 'Tidur 8 Jam',
        description: 'Tidur cukup 7-8 jam setiap malam untuk pemulihan tubuh optimal',
        category: 'Kesehatan',
        icon: 'bedtime',
        color: 0xFF9C27B0,
        tags: ['tidur', 'istirahat', 'kesehatan'],
        difficulty: 'medium',
      ),

      // Olahraga
      const HabitTemplate(
        title: 'Jalan Kaki 30 Menit',
        description: 'Berjalan kaki minimal 30 menit setiap hari untuk menjaga kebugaran',
        category: 'Olahraga',
        icon: 'directions_walk',
        color: 0xFFF44336,
        tags: ['kardio', 'jalan', 'mudah'],
        difficulty: 'easy',
      ),
      const HabitTemplate(
        title: 'Push Up 20x',
        description: 'Melakukan 20 push up untuk melatih kekuatan otot dada dan lengan',
        category: 'Olahraga',
        icon: 'fitness_center',
        color: 0xFFFF9800,
        tags: ['kekuatan', 'otot', 'rumah'],
        difficulty: 'medium',
      ),
      const HabitTemplate(
        title: 'Yoga 15 Menit',
        description: 'Sesi yoga singkat untuk fleksibilitas dan ketenangan pikiran',
        category: 'Olahraga',
        icon: 'spa',
        color: 0xFF00BCD4,
        tags: ['yoga', 'fleksibilitas', 'relaksasi'],
        difficulty: 'easy',
      ),

      // Belajar
      const HabitTemplate(
        title: 'Baca Buku 30 Menit',
        description: 'Membaca buku minimal 30 menit setiap hari untuk menambah wawasan',
        category: 'Belajar',
        icon: 'book',
        color: 0xFF2196F3,
        tags: ['membaca', 'pengetahuan', 'wawasan'],
        difficulty: 'easy',
      ),
      const HabitTemplate(
        title: 'Belajar Bahasa Asing',
        description: 'Belajar bahasa asing 20 menit setiap hari menggunakan aplikasi',
        category: 'Belajar',
        icon: 'language',
        color: 0xFF673AB7,
        tags: ['bahasa', 'skill', 'komunikasi'],
        difficulty: 'medium',
      ),
      const HabitTemplate(
        title: 'Menulis Jurnal',
        description: 'Menulis jurnal harian untuk refleksi dan pengembangan diri',
        category: 'Belajar',
        icon: 'edit_note',
        color: 0xFF795548,
        tags: ['menulis', 'refleksi', 'jurnal'],
        difficulty: 'easy',
      ),

      // Kerja
      const HabitTemplate(
        title: 'Review Email Pagi',
        description: 'Mengecek dan membalas email penting setiap pagi',
        category: 'Kerja',
        icon: 'email',
        color: 0xFFFF9800,
        tags: ['email', 'produktivitas', 'komunikasi'],
        difficulty: 'easy',
      ),
      const HabitTemplate(
        title: 'Planning Harian',
        description: 'Membuat rencana dan prioritas tugas untuk hari ini',
        category: 'Kerja',
        icon: 'event_note',
        color: 0xFF3F51B5,
        tags: ['planning', 'organisasi', 'produktivitas'],
        difficulty: 'easy',
      ),

      // Hobi
      const HabitTemplate(
        title: 'Menggambar 15 Menit',
        description: 'Meluangkan waktu untuk menggambar atau sketsa setiap hari',
        category: 'Hobi',
        icon: 'brush',
        color: 0xFF9C27B0,
        tags: ['seni', 'kreativitas', 'menggambar'],
        difficulty: 'easy',
      ),
      const HabitTemplate(
        title: 'Bermain Musik',
        description: 'Berlatih bermain alat musik favorit selama 30 menit',
        category: 'Hobi',
        icon: 'music_note',
        color: 0xFFE91E63,
        tags: ['musik', 'alat musik', 'kreativitas'],
        difficulty: 'medium',
      ),
      const HabitTemplate(
        title: 'Fotografi Harian',
        description: 'Mengambil minimal satu foto menarik setiap hari',
        category: 'Hobi',
        icon: 'camera_alt',
        color: 0xFF607D8B,
        tags: ['fotografi', 'kreativitas', 'dokumentasi'],
        difficulty: 'easy',
      ),

      // Spiritual/Mental
      const HabitTemplate(
        title: 'Meditasi 10 Menit',
        description: 'Sesi meditasi singkat untuk ketenangan pikiran dan fokus',
        category: 'Kesehatan',
        icon: 'self_improvement',
        color: 0xFF4CAF50,
        tags: ['meditasi', 'mental', 'ketenangan'],
        difficulty: 'easy',
      ),
      const HabitTemplate(
        title: 'Bersyukur 3 Hal',
        description: 'Menulis 3 hal yang disyukuri setiap hari',
        category: 'Kesehatan',
        icon: 'favorite',
        color: 0xFFE91E63,
        tags: ['syukur', 'positif', 'mental'],
        difficulty: 'easy',
      ),
    ];
  }

  static List<HabitTemplate> getTemplatesByCategory(String category) {
    return getDefaultTemplates()
        .where((template) => template.category == category)
        .toList();
  }

  static List<HabitTemplate> getTemplatesByDifficulty(String difficulty) {
    return getDefaultTemplates()
        .where((template) => template.difficulty == difficulty)
        .toList();
  }

  static List<HabitTemplate> searchTemplates(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getDefaultTemplates().where((template) {
      return template.title.toLowerCase().contains(lowercaseQuery) ||
             template.description.toLowerCase().contains(lowercaseQuery) ||
             template.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static List<String> getAllCategories() {
    return getDefaultTemplates()
        .map((template) => template.category)
        .toSet()
        .toList();
  }

  static List<String> getAllTags() {
    final allTags = <String>{};
    for (final template in getDefaultTemplates()) {
      allTags.addAll(template.tags);
    }
    return allTags.toList()..sort();
  }
}