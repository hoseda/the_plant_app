class Plant {
  final int plantId;
  final int price;
  final String size;
  final double rating;
  final int humidity;
  final String temperature;
  final String category;
  final String plantName;
  final String imageURL;
  bool isFavorated;
  final String decription;
  bool isSelected;

  Plant({
    required this.plantId,
    required this.price,
    required this.category,
    required this.plantName,
    required this.size,
    required this.rating,
    required this.humidity,
    required this.temperature,
    required this.imageURL,
    required this.isFavorated,
    required this.decription,
    required this.isSelected,
  });

  // List of Plants data - Updated with new plants
  static List<Plant> plantList = [
    // Plant 0 - یوکا
    Plant(
      plantId: 0,
      price: 3000000, // Average of range 1.5M - 5M
      category: 'آپارتمانی',
      plantName: 'یوکا',
      size: 'بزرگ',
      rating: 4.6,
      humidity: 30, // کم
      temperature: '18 - 30',
      imageURL: 'assets/images/temp/Yucca.png',
      isFavorated: false,
      decription:
          'یوکا گیاهی مقاوم با تنه چوبی و برگ‌های شمشیری است که برای فضاهای بزرگ و پرنور بسیار مناسب می‌باشد. نیاز آبی کمی دارد و در برابر خشکی و کم‌توجهی مقاومت بالایی نشان می‌دهد.',
      isSelected: false,
    ),

    // Plant 1 - کاج مطبق
    Plant(
      plantId: 1,
      price: 5000000, // Average of range 2M - 8M
      category: 'آپارتمانی',
      plantName: 'کاج مطبق',
      size: 'بزرگ',
      rating: 4.8,
      humidity: 65, // متوسط تا زیاد
      temperature: '16 - 24',
      imageURL: 'assets/images/temp/Kaj motabagh.png',
      isFavorated: false,
      decription:
          'کاج مطبق گیاهی لوکس و دکوراتیو با رشد آهسته است که ظاهر آن شبیه درخت کاج می‌باشد. به رطوبت هوا حساس است و برای نگهداری سالم، نیاز به محیطی خنک و نور غیرمستقیم دارد.',
      isSelected: false,
    ),

    // Plant 2 - فردوس
    Plant(
      plantId: 2,
      price: 1000000, // Average of range 600K - 1.5M
      category: 'پیشنهادی',
      plantName: 'فردوس',
      size: 'متوسط',
      rating: 4.5,
      humidity: 50, // متوسط
      temperature: '18 - 28',
      imageURL: 'assets/images/temp/Ferdos.png',
      isFavorated: false,
      decription:
          'فردوس گیاهی آپارتمانی با برگ‌های سبز و براق است که نگهداری آسانی دارد و برای افراد مبتدی گزینه‌ای مناسب محسوب می‌شود.',
      isSelected: false,
    ),

    // Plant 3 - شامادورا
    Plant(
      plantId: 3,
      price: 1600000, // Average of range 700K - 2.5M
      category: 'محل‌کار',
      plantName: 'شامادورا',
      size: 'متوسط',
      rating: 4.4,
      humidity: 60, // متوسط تا زیاد
      temperature: '18 - 26',
      imageURL: 'assets/images/temp/Shamadora.png',
      isFavorated: false,
      decription:
          'شامادورا نخل آپارتمانی محبوبی است که در نور کم نیز به‌خوبی رشد می‌کند و به بهبود کیفیت هوای محیط کمک می‌کند.',
      isSelected: false,
    ),

    // Plant 4 - پتوس آویز
    Plant(
      plantId: 4,
      price: 750000, // Average of range 300K - 1.2M
      category: 'پیشنهادی',
      plantName: 'پتوس آویز',
      size: 'متوسط',
      rating: 4.7,
      humidity: 50, // متوسط
      temperature: '18 - 30',
      imageURL: 'assets/images/temp/Petos aviz.png',
      isFavorated: false,
      decription:
          'پتوس آویز گیاهی رونده و بسیار مقاوم است که برای گلدان‌های آویز و دکوراسیون داخلی انتخابی عالی می‌باشد.',
      isSelected: false,
    ),

    // Plant 5 - شفلرا ابلق
    Plant(
      plantId: 5,
      price: 2200000, // Average of range 900K - 3.5M
      category: 'آپارتمانی',
      plantName: 'شفلرا ابلق',
      size: 'بزرگ',
      rating: 4.5,
      humidity: 50, // متوسط
      temperature: '18 - 27',
      imageURL: 'assets/images/temp/Sheflera.png',
      isFavorated: false,
      decription:
          'شفلرا ابلق با برگ‌های براق و چندرنگ جلوه‌ای خاص به فضای داخلی می‌دهد و نیازمند نور غیرمستقیم است.',
      isSelected: false,
    ),

    // Plant 6 - دیفن باخیا
    Plant(
      plantId: 6,
      price: 1250000, // Average of range 500K - 2M
      category: 'آپارتمانی',
      plantName: 'دیفن باخیا',
      size: 'متوسط',
      rating: 4.3,
      humidity: 70, // زیاد
      temperature: '18 - 28',
      imageURL: 'assets/images/temp/Difin bakhia.png',
      isFavorated: false,
      decription:
          'دیفن‌باخیا گیاهی برگ‌تزئینی با برگ‌های درشت است که به رطوبت بالا علاقه دارد و برای فضای داخلی مناسب است.',
      isSelected: false,
    ),

    // Plant 7 - فیلودندرون
    Plant(
      plantId: 7,
      price: 1800000, // Average of range 600K - 3M
      category: 'محل‌کار',
      plantName: 'فیلودندرون',
      size: 'متوسط',
      rating: 4.6,
      humidity: 60, // متوسط تا زیاد
      temperature: '18 - 30',
      imageURL: 'assets/images/temp/Philodendron.png',
      isFavorated: false,
      decription:
          'فیلودندرون گیاهی محبوب با نگهداری آسان است که در نور غیرمستقیم رشد خوبی دارد.',
      isSelected: false,
    ),

    // Plant 8 - زاموفیلیا
    Plant(
      plantId: 8,
      price: 2100000, // Average of range 700K - 3.5M
      category: 'محل‌کار',
      plantName: 'زاموفیلیا',
      size: 'متوسط',
      rating: 4.8,
      humidity: 35, // کم
      temperature: '18 - 30',
      imageURL: 'assets/images/temp/Zamofilia.png',
      isFavorated: false,
      decription:
          'زاموفیلیا گیاهی بسیار مقاوم است که به کم‌آبی و نور کم سازگار می‌باشد.',
      isSelected: false,
    ),

    // Plant 9 - اسپاتی فیلوم
    Plant(
      plantId: 9,
      price: 1550000, // Average of range 600K - 2.5M
      category: 'آپارتمانی',
      plantName: 'اسپاتی فیلوم',
      size: 'متوسط',
      rating: 4.7,
      humidity: 70, // زیاد
      temperature: '18 - 26',
      imageURL: 'assets/images/temp/Spati filom.png',
      isFavorated: false,
      decription:
          'اسپاتی فیلوم گیاهی گل‌دهنده با گل‌های سفید زیبا است و به رطوبت علاقه دارد.',
      isSelected: false,
    ),

    // Plant 10 - آگلونما پینک لیدی
    Plant(
      plantId: 10,
      price: 2600000, // Average of range 1.2M - 4M
      category: 'پیشنهادی',
      plantName: 'آگلونما پینک لیدی',
      size: 'متوسط',
      rating: 4.9,
      humidity: 55, // متوسط
      temperature: '18 - 28',
      imageURL: 'assets/images/temp/Aglonema.png',
      isFavorated: false,
      decription:
          'آگلونما پینک لیدی با برگ‌های صورتی و سبز جلوه‌ای خاص دارد و در نور کم نیز زیبا می‌ماند.',
      isSelected: false,
    ),

    // Plant 11 - فیکوس بونسای
    Plant(
      plantId: 11,
      price: 6000000, // Average of range 2M - 10M
      category: 'محل‌کار',
      plantName: 'فیکوس بونسای',
      size: 'کوچک',
      rating: 4.7,
      humidity: 50, // متوسط
      temperature: '18 - 26',
      imageURL: 'assets/images/temp/Ficos.png',
      isFavorated: false,
      decription:
          'فیکوس بونسای گیاهی دکوراتیو است که نیاز به هرس و مراقبت منظم دارد.',
      isSelected: false,
    ),

    // Plant 12 - افوربیا
    Plant(
      plantId: 12,
      price: 3500000, // Average of range 1M - 6M
      category: 'باغچه‌ای',
      plantName: 'افوربیا',
      size: 'بزرگ',
      rating: 4.3,
      humidity: 30, // کم
      temperature: '20 - 35',
      imageURL: 'assets/images/temp/Aforbia.png',
      isFavorated: false,
      decription: 'افوربیا گیاهی مقاوم شبیه کاکتوس است که شیره‌ای سمی دارد.',
      isSelected: false,
    ),

    // Plant 13 - قاشقی
    Plant(
      plantId: 13,
      price: 800000, // Average of range 400K - 1.2M
      category: 'محل‌کار',
      plantName: 'قاشقی',
      size: 'کوچک',
      rating: 4.4,
      humidity: 50, // متوسط
      temperature: '18 - 27',
      imageURL: 'assets/images/temp/Ghashoghi.png',
      isFavorated: false,
      decription: 'قاشقی گیاهی جمع‌وجور و مناسب فضاهای کوچک مانند میز کار است.',
      isSelected: false,
    ),

    // Plant 14 - سانسوریا
    Plant(
      plantId: 14,
      price: 1750000, // Average of range 500K - 3M
      category: 'آپارتمانی',
      plantName: 'سانسوریا',
      size: 'بزرگ',
      rating: 4.8,
      humidity: 30, // کم
      temperature: '15 - 30',
      imageURL: 'assets/images/temp/Sanseveria.png',
      isFavorated: false,
      decription: 'سانسوریا گیاهی بسیار مقاوم و مناسب تصفیه هوای محیط است.',
      isSelected: false,
    ),

    // Plant 15 - گندمی
    Plant(
      plantId: 15,
      price: 600000, // Average of range 300K - 900K
      category: 'پیشنهادی',
      plantName: 'گندمی',
      size: 'کوچک',
      rating: 4.5,
      humidity: 50, // متوسط
      temperature: '16 - 26',
      imageURL: 'assets/images/temp/Ghandomi.png',
      isFavorated: false,
      decription: 'گندمی گیاهی شاداب با رشد سریع و تکثیر آسان است.',
      isSelected: false,
    ),

    // Plant 16 - قهر و آشتی
    Plant(
      plantId: 16,
      price: 675000, // Average of range 350K - 1M
      category: 'آپارتمانی',
      plantName: 'قهر و آشتی',
      size: 'کوچک',
      rating: 4.6,
      humidity: 50, // متوسط
      temperature: '18 - 26',
      imageURL: 'assets/images/temp/Ghahr ashti.png',
      isFavorated: false,
      decription: 'این گیاه به حرکات برگ‌هایش معروف است که شب‌ها جمع می‌شوند.',
      isSelected: false,
    ),

    // Plant 17 - حسن یوسف
    Plant(
      plantId: 17,
      price: 525000, // Average of range 250K - 800K
      category: 'باغچه‌ای',
      plantName: 'حسن یوسف',
      size: 'متوسط',
      rating: 4.4,
      humidity: 50, // متوسط
      temperature: '18 - 30',
      imageURL: 'assets/images/temp/Hosn yosof.png',
      isFavorated: false,
      decription:
          'حسن یوسف گیاهی رنگارنگ با برگ‌های جذاب است که نور غیرمستقیم را دوست دارد.',
      isSelected: false,
    ),
  ];

  // Get the favorated items
  static List<Plant> getFavoritedPlants() {
    List<Plant> travelList = Plant.plantList;
    return travelList.where((element) => element.isFavorated == true).toList();
  }

  // Get the cart items
  static List<Plant> addedToCartPlants() {
    List<Plant> selectedPlants = Plant.plantList;
    return selectedPlants
        .where((element) => element.isSelected == true)
        .toList();
  }
}
