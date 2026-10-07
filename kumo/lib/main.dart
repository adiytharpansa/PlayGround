import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Model ──────────────────────────────────────────────

class Anime {
  final int id;
  final String title;
  final List<String> genres;
  final double rating;
  final String status; // Tayang | Tamat | Baru
  final int episodes;
  final String desc;
  final double hue;

  const Anime({
    required this.id,
    required this.title,
    required this.genres,
    required this.rating,
    required this.status,
    required this.episodes,
    required this.desc,
    required this.hue,
  });
}

const List<Anime> kAnime = [
  Anime(id: 0, title: 'Langit Terakhir', genres: ['Aksi', 'Petualangan'], rating: 8.7, status: 'Tayang', episodes: 64, desc: 'Seorang kurir awan mencari pulau terakhir yang masih melayang di atas lautan badai.', hue: 330),
  Anime(id: 1, title: 'Detektif Senja', genres: ['Misteri', 'Drama'], rating: 8.4, status: 'Tayang', episodes: 120, desc: 'Detektif SMA memecahkan kasus aneh yang selalu terjadi saat matahari terbenam.', hue: 17),
  Anime(id: 2, title: 'Re: Zona Nol', genres: ['Fantasi', 'Thriller'], rating: 8.9, status: 'Tamat', episodes: 50, desc: 'Setiap kali gagal, dunia mengulang dari awal. Hanya dia yang ingat semuanya.', hue: 64),
  Anime(id: 3, title: 'Bintang Berpacu', genres: ['Olahraga', 'Aksi'], rating: 8.1, status: 'Tayang', episodes: 24, desc: 'Balapan lintas benua dengan hadiah satu permintaan apa pun.', hue: 111),
  Anime(id: 4, title: 'Penyihir Hitam', genres: ['Fantasi', 'Aksi'], rating: 8.3, status: 'Tayang', episodes: 170, desc: 'Anak tanpa sihir bersumpah menjadi raja penyihir bersama sahabatnya.', hue: 158),
  Anime(id: 5, title: 'Naga Biru', genres: ['Aksi', 'Fantasi'], rating: 7.9, status: 'Baru', episodes: 12, desc: 'Seorang pemburu bertemu naga yang takut ketinggian.', hue: 205),
  Anime(id: 6, title: 'Kafe Pukul Tiga', genres: ['Komedi', 'Slice of Life'], rating: 8.0, status: 'Tayang', episodes: 36, desc: 'Kafe kecil yang hanya buka tengah malam.', hue: 252),
  Anime(id: 7, title: 'Sekolah Gema', genres: ['Romantis', 'Drama'], rating: 7.8, status: 'Tamat', episodes: 13, desc: 'Dua siswa saling berkirim catatan lewat loker kosong.', hue: 299),
  Anime(id: 8, title: 'Dapur Dewa', genres: ['Komedi', 'Kuliner'], rating: 7.7, status: 'Tayang', episodes: 30, desc: 'Koki muda menantang para dewa memasak di dapur surga.', hue: 346),
  Anime(id: 9, title: 'Kapal Kertas', genres: ['Petualangan', 'Komedi'], rating: 8.5, status: 'Tayang', episodes: 90, desc: 'Kru kapal kertas menyeberangi samudra sebelum hujan turun.', hue: 33),
  Anime(id: 10, title: 'Mesin Hati', genres: ['Sci-Fi', 'Drama'], rating: 8.6, status: 'Baru', episodes: 12, desc: 'Robot perbaikan belajar apa artinya merindukan seseorang.', hue: 80),
  Anime(id: 11, title: 'Pedang Sunyi', genres: ['Aksi', 'Sejarah'], rating: 8.2, status: 'Tamat', episodes: 26, desc: 'Ronin tanpa suara menjaga desa dari bayangan masa lalu.', hue: 127),
];

LinearGradient gradientFor(Anime a) {
  final c1 = HSLColor.fromAHSL(1, a.hue, 0.70, 0.55).toColor();
  final c2 = HSLColor.fromAHSL(1, (a.hue + 40) % 360, 0.65, 0.35).toColor();
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [c1, c2],
  );
}

// ─── State ──────────────────────────────────────────────

class AppState extends ChangeNotifier {
  int tab = 0;
  int heroIndex = 0;
  String? genreFilter;
  String query = '';
  Set<int> myList = {};
  ThemeMode themeMode = ThemeMode.system;

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      myList = (p.getStringList('kumo') ?? []).map(int.parse).toSet();
      final t = p.getString('kumoTheme') ?? 'auto';
      themeMode = t == 'light'
          ? ThemeMode.light
          : t == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system;
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList('kumo', myList.map((e) => '$e').toList());
      await p.setString(
          'kumoTheme',
          themeMode == ThemeMode.light
              ? 'light'
              : themeMode == ThemeMode.dark
                  ? 'dark'
                  : 'auto');
    } catch (_) {}
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  void setHero(int i) {
    heroIndex = i;
    notifyListeners();
  }

  void setGenre(String? g) {
    genreFilter = (genreFilter == g) ? null : g;
    notifyListeners();
  }

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  bool toggleList(int id) {
    final added;
    if (myList.contains(id)) {
      myList.remove(id);
      added = false;
    } else {
      myList.add(id);
      added = true;
    }
    _save();
    notifyListeners();
    return added;
  }

  void clearList() {
    myList.clear();
    _save();
    notifyListeners();
  }

  void cycleTheme() {
    themeMode = themeMode == ThemeMode.system
        ? ThemeMode.light
        : themeMode == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.system;
    _save();
    notifyListeners();
  }
}

// ─── App ────────────────────────────────────────────────

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => AppState()..load(),
    child: const KumoApp(),
  ));
}

class KumoApp extends StatelessWidget {
  const KumoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppState>().themeMode;
    const seed = Color(0xFFF0457A);
    return MaterialApp(
      title: 'Kumo – Nonton Anime',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        scaffoldBackgroundColor: const Color(0xFFF6F4FB),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0B1A),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('kumo.',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              child: IconButton(
                icon: const Icon(Icons.person, size: 20),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: st.tab,
        children: const [
          HomeScreen(),
          GenreScreen(),
          LatestScreen(),
          SearchScreen(),
          MyListScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: st.tab,
        onDestinationSelected: st.setTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Genre'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Terbaru'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Cari'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Daftarku'),
        ],
      ),
    );
  }
}

// ─── Widgets ────────────────────────────────────────────

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final double? width; // null = fill grid cell
  const AnimeCard(this.anime, {this.width = 132, super.key});

  @override
  Widget build(BuildContext context) {
    final inList = context.watch<AppState>().myList.contains(anime.id);
    final poster = AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradientFor(anime),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8)),
          ],
        ),
              child: Stack(
                children: [
                  if (anime.status == 'Baru')
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFF0457A), Color(0xFF8B5CF6)]),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Text('Baru',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(99)),
                      child: Text('★ ${anime.rating}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  Positioned(
                    left: 10, right: 10, bottom: 10,
                    child: Text(anime.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
                  ),
                  if (inList)
                    const Positioned(
                      bottom: 8, right: 8,
                      child: Icon(Icons.favorite, size: 14, color: Colors.white70),
                    ),
                ],
              ),
      ),
    );
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(onTap: () => showDetail(context, anime), child: poster),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(anime.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        Text('★ ${anime.rating} · ${anime.genres.first}',
            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
      ],
    );
    if (width == null) return body;
    return SizedBox(width: width, child: body);
  }
}

Future<void> showDetail(BuildContext context, Anime anime) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => DetailSheet(anime: anime, controller: controller),
    ),
  );
}

class DetailSheet extends StatelessWidget {
  final Anime anime;
  final ScrollController controller;
  const DetailSheet({required this.anime, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final saved = st.myList.contains(anime.id);
    final n = anime.episodes < 8 ? anime.episodes : 8;
    return ListView(
      controller: controller,
      children: [
        Container(
          height: 230,
          decoration: BoxDecoration(
            gradient: gradientFor(anime),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(18),
          child: Text(anime.title,
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (final s in ['★ ${anime.rating}\nRating', '${anime.episodes}\nEpisode', '${anime.status}\nStatus'])
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(s, textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: anime.genres
                    .map((g) => Chip(label: Text(g, style: const TextStyle(fontSize: 12))))
                    .toList(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(anime.desc,
                    style: TextStyle(
                        fontSize: 14.5, height: 1.6, color: Theme.of(context).hintColor)),
              ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlayerScreen(anime: anime, episode: 1)),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Tonton'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      final added = st.toggleList(anime.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(added
                              ? 'Ditambahkan ke Daftarku'
                              : 'Dihapus dari Daftarku')));
                    },
                    icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
                    label: Text(saved ? 'Di daftar' : 'Daftarku'),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8),
                child: Text('Episode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
              for (var i = 0; i < n; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 90,
                    height: 56,
                    decoration: BoxDecoration(
                        gradient: gradientFor(anime),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                  title: Text('Episode ${anime.episodes - i}'),
                  subtitle: const Text('24 mnt'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PlayerScreen(
                            anime: anime, episode: anime.episodes - i)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Screens ────────────────────────────────────────────

List<Anime> heroPicks() {
  final baru = kAnime.where((a) => a.status == 'Baru').toList();
  final rest = kAnime.where((a) => a.status != 'Baru').toList()
    ..sort((x, y) => y.rating.compareTo(x.rating));
  return [...baru, ...rest].take(3).toList();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  final _page = PageController();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      final picks = heroPicks();
      final next = (context.read<AppState>().heroIndex + 1) % picks.length;
      context.read<AppState>().setHero(next);
      if (_page.hasClients) {
        _page.animateToPage(next,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final picks = heroPicks();
    final top = [...kAnime]..sort((x, y) => y.rating.compareTo(x.rating));
    final baru = kAnime.where((a) => a.status == 'Baru').toList();

    return ListView(
      children: [
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _page,
            itemCount: picks.length,
            onPageChanged: st.setHero,
            itemBuilder: (_, i) {
              final a = picks[i];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                decoration: BoxDecoration(
                    gradient: gradientFor(a),
                    borderRadius: BorderRadius.circular(28)),
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(a.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 0.98)),
                    const SizedBox(height: 10),
                    Text('★ ${a.rating} · ${a.status} · ${a.episodes} Episode',
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(a.genres.join(', '),
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF16132E)),
                            onPressed: () => showDetail(context, a),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Tonton'),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final added = st.toggleList(a.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(added
                                        ? 'Ditambahkan ke Daftarku'
                                        : 'Dihapus dari Daftarku')));
                          },
                          icon: Icon(
                              st.myList.contains(a.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(picks.length, (i) {
            return Container(
              width: 24, height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i == st.heroIndex
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(9),
              ),
            );
          }),
        ),
        const SectionTitle('Lanjutkan menonton'),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              final a = kAnime[i];
              return SizedBox(
                width: 232,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => showDetail(context, a),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                            gradient: gradientFor(a),
                            borderRadius: BorderRadius.circular(16)),
                        child: const Center(
                            child: Icon(Icons.play_circle_fill,
                                color: Colors.white, size: 44)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(a.title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text('Episode 5 · sisa 12 mnt',
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).hintColor)),
                    const SizedBox(height: 6),
                    const LinearProgressIndicator(value: 0.6),
                  ],
                ),
              );
            },
          ),
        ),
        const SectionTitle('Baru rilis'),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: baru.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) =>
                GestureDetector(onTap: () => showDetail(context, baru[i]), child: AnimeCard(baru[i])),
          ),
        ),
        const SectionTitle('Spotlight'),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: top.length > 8 ? 8 : top.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) =>
                GestureDetector(onTap: () => showDetail(context, top[i]), child: AnimeCard(top[i])),
          ),
        ),
        const SectionTitle('Top 10 minggu ini'),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: top.length > 10 ? 10 : top.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${i + 1}',
                      style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w800,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2
                            ..color = Theme.of(context).colorScheme.primary)),
                  GestureDetector(
                      onTap: () => showDetail(context, top[i]),
                      child: AnimeCard(top[i])),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final genres = kAnime.expand((a) => a.genres).toSet().toList()..sort();
    final list = kAnime
        .where((a) => st.genreFilter == null || a.genres.contains(st.genreFilter))
        .toList();
    return ListView(
      children: [
        const SectionTitle('Genre'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: genres.map((g) {
              final on = st.genreFilter == g;
              return ChoiceChip(
                label: Text(g),
                selected: on,
                onSelected: (_) => st.setGenre(g),
              );
            }).toList(),
          ),
        ),
        SectionTitle('${list.length} anime'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 14, mainAxisSpacing: 14),
            itemCount: list.length,
            itemBuilder: (_, i) => GestureDetector(
                onTap: () => showDetail(context, list[i]),
                child: AnimeCard(list[i], width: null)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class LatestScreen extends StatelessWidget {
  const LatestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = [...kAnime]..sort((x, y) => y.episodes.compareTo(x.episodes));
    return ListView(
      children: [
        const SectionTitle('Episode terbaru'),
        for (final a in list.take(6))
          Card(
            margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: ListTile(
              leading: Container(
                width: 80,
                decoration: BoxDecoration(
                    gradient: gradientFor(a),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
              title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Episode ${a.episodes}'),
              onTap: () => showDetail(context, a),
            ),
          ),
      ],
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    if (_ctrl.text != st.query) {
      _ctrl.value = TextEditingValue(
        text: st.query,
        selection: TextSelection.collapsed(offset: st.query.length),
      );
    }
    final q = st.query.toLowerCase();
    final list = kAnime
        .where((a) => (a.title + a.genres.join()).toLowerCase().contains(q))
        .toList();
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: 'Cari judul atau genre',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(99))),
            ),
            onChanged: st.setQuery,
          ),
        ),
        SectionTitle(st.query.isEmpty ? 'Semua anime' : 'Hasil'),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('Tidak ada hasil. Coba kata lain atau cek ejaan.'),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 14, mainAxisSpacing: 14),
              itemCount: list.length,
              itemBuilder: (_, i) => GestureDetector(
                  onTap: () => showDetail(context, list[i]),
                  child: AnimeCard(list[i], width: null)),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class MyListScreen extends StatelessWidget {
  const MyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final list = kAnime.where((a) => st.myList.contains(a.id)).toList();
    return ListView(
      children: [
        SectionTitle('Daftarku (${list.length})'),
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('Belum ada anime di daftar. Ketuk ♡ pada anime.'),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 14, mainAxisSpacing: 14),
              itemCount: list.length,
              itemBuilder: (_, i) => GestureDetector(
                  onTap: () => showDetail(context, list[i]),
                  child: AnimeCard(list[i], width: null)),
            ),
          ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    String themeLabel(ThemeMode m) =>
        m == ThemeMode.light ? 'Terang' : m == ThemeMode.dark ? 'Gelap' : 'Otomatis';
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('${st.myList.length}\nDaftarku',
                              textAlign: TextAlign.center))),
                ),
                Expanded(
                  child: Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('${kAnime.length}\nAnime',
                              textAlign: TextAlign.center))),
                ),
                const Expanded(
                  child: Card(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('12\nEpisode',
                              textAlign: TextAlign.center))),
                ),
              ],
            ),
          ),
          const SectionTitle('Pengaturan'),
          ListTile(
            title: const Text('Tema tampilan'),
            trailing: Text(themeLabel(st.themeMode)),
            onTap: st.cycleTheme,
          ),
          ListTile(
            title: const Text('Hapus daftar'),
            trailing: const Icon(Icons.delete_outline),
            onTap: () {
              st.clearList();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Daftar dihapus')));
            },
          ),
        ],
      ),
    );
  }
}

// ─── Player (pratinjau, tanpa video) ────────────────────

class PlayerScreen extends StatefulWidget {
  final Anime anime;
  final int episode;
  const PlayerScreen({required this.anime, required this.episode, super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool playing = true;
  double pos = 0;
  final double total = 24 * 60;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !playing) return;
      setState(() {
        pos = (pos + 1).clamp(0, total);
        if (pos >= total) playing = false;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String fmt(double x) {
    final s = x.floor();
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${widget.anime.title} · Ep ${widget.episode}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: gradientFor(widget.anime),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: IconButton(
                  iconSize: 72,
                  color: Colors.white,
                  icon: Icon(playing
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill),
                  onPressed: () => setState(() => playing = !playing),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Slider(
                    value: pos,
                    max: total,
                    activeColor: const Color(0xFFF0457A),
                    onChanged: (v) => setState(() => pos = v)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fmt(pos),
                        style: const TextStyle(color: Colors.white)),
                    Text('-${fmt(total - pos)}',
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Pratinjau tanpa video — hubungkan URL streaming / HLS di sini.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.replay_10),
                        onPressed: () =>
                            setState(() => pos = (pos - 10).clamp(0, total))),
                    const SizedBox(width: 16),
                    IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.forward_10),
                        onPressed: () =>
                            setState(() => pos = (pos + 10).clamp(0, total))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
