import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

// ---------------------------------------------------------------------------
// СЛОВАРЬ (слова из 5 букв, русский язык)
// ---------------------------------------------------------------------------

const String _rawWords = '''
автор агент адрес актер аллея ангел арбуз арена армия астра атака бабка багаж банда банка баран баржа башня бегун белка берег бетон бизон билет бланк блуза блюдо бокал бочка бровь брюки буква булка вагон вальс вафля ведро венок верба весло весна ветер ветка вечер взвод визит вилка вирус вишня вклад водка вокал волна ворон выбор вывод выход вьюга газон гайка галка гамак гараж гарем гений герой глаза глина голод голос гонец гонка горка город горох гость грива гроза грудь груша гряда гусар гусли дамба дверь демон диван добро дождь доска доход дочка драка драма дробь дрова дрожь дрозд дубль дубок дурак дуэль дымка дымок дятел ересь жажда желуд жених живот жизнь жилет жилка жилье жираф жрица жулик жучок забор завод зайка закат закон залив залог замок запад запас запах затея зачет звено зверь зебра земля зерно злоба знамя зубец игрок идеал икона икота имидж индюк инжир ирбис искра испуг исток иудей карта каска кепка кефир кисть клише клоун книга кобра ковер козел колба колос комар комод конец копье корка корма кость кофта кошка крест кровь крыло крыса крыша кубок кузен кузов кукла кулак кулон кумир купец купол кусок кухня лавка лавра ладья лазер лайка лампа ларек ласка левша лента лидер лимон линза линия лицей лодка ложка ломка лопух лоток лотос лучик магия малыш манго манеж марка маска масло мачта медик мелок метка метла метро мечта мешок мираж миска мишка молот монах морда мороз мотив мотор мошка музей мусор мышка мышца мятеж народ наука нация нитка ногти ножик номер норка носок ночка оазис обзор обман образ обруч обрыв обряд обувь овощи овраг огонь озеро округ окунь олень олива омлет опера оплот орган орден осень осина оскал особа осока отдых отзыв отряд отчет палец палка панда папка парад парта парус пасть пауза пенал пенка перец перья песня песок печка пилка пилот пинок пират пирог пицца пламя плата плеер плечо плита повар погон пожар позор показ полет полка полюс порог порок порох посох почка почта поэма право прием принц проба проза пряжа птица пудра пульт пункт пурга пушка пчела пшено пьеса пятка пятно радар радио район рамка ранец рвота рейка речка робот рожок роман ротор рояль рубеж рубль ружье рулон русло ручей ручка рыбак рынок рюмка ряска сабля садик салат салон салют самец самка санки сапог сарай сахар свеча север седло сезон секта семья сетка синус ситец скала склад склон скоба скрип слеза слива слово смена смесь смола собор совет совок сокол солод сонет сосед соска сосна спина спирт спица спорт спрут спуск среда ссора ссуда стадо стена стопа страх стриж струя ступа сумка сумма сутки сфера схема съезд сырок сюжет сюита табак табун тайна такси талон танец таран тачка твист театр тезис текст телка терем терка тесто тесть тетка тираж титул ткань товар толпа тоска точка трава трель треск труба туман тумба турок туфля тучка тыква тягач удача удила узник уклон уксус улика улица умник унция упрек успех учеба фазан факел фасад фасон фикус фильм финал финик фирма фишка фляга форма фраза фреза фронт фрукт фужер халат халва ханжа хвост хлыст хобби хобот холка холод холст хомут хомяк хорек хруст хутор цапля центр цифра цыган чайка чалма чарка чашка череп черта честь четка чехол число чудак чулан чулок чутье шабаш шайба шайка шакал шалаш шапка шарик шатер шахта шашка шепот шериф ширма шишка школа шкура шланг шляпа шорты шоссе шофер шприц штаны штора штраф штука штурм шумок шутка щенок щепка щетка экран эмаль эскиз юноша ягода якорь
''';

final List<String> russianWords = _rawWords
    .split(RegExp(r'\s+'))
    .where((w) => w.length == 5)
    .toSet()
    .toList();

// ---------------------------------------------------------------------------
// МОДЕЛЬ ИГРЫ
// ---------------------------------------------------------------------------

enum HitType { none, hit, partial, miss }

enum GameState { playing, won, lost }

class Letter {
  const Letter(this.char, this.type);

  final String char;
  final HitType type;
}

class Game {
  Game({List<String>? dictionary, String? answer})
      : dictionary = dictionary ?? russianWords,
        answer = answer ??
            (dictionary ?? russianWords)[
                Random().nextInt((dictionary ?? russianWords).length)];

  static const int wordLength = 5;
  static const int maxAttempts = 6;

  final List<String> dictionary;
  final String answer;
  final List<List<Letter>> guesses = [];

  GameState get state {
    if (guesses.isNotEmpty && guesses.last.every((l) => l.type == HitType.hit)) {
      return GameState.won;
    }
    if (guesses.length >= maxAttempts) return GameState.lost;
    return GameState.playing;
  }

  /// Приводим ввод к единому виду: нижний регистр, «ё» -> «е».
  static String normalize(String input) =>
      input.trim().toLowerCase().replaceAll('ё', 'е');

  bool isValidWord(String word) => dictionary.contains(word);

  /// Проверяет слово. Возвращает null, если всё хорошо, иначе — текст ошибки.
  String? submitGuess(String input) {
    if (state != GameState.playing) return 'Игра уже окончена';

    final word = normalize(input);
    if (word.length != wordLength) {
      return 'Нужно слово из $wordLength букв';
    }
    if (!RegExp(r'^[а-я]+$').hasMatch(word)) {
      return 'Используйте только русские буквы';
    }
    if (!isValidWord(word)) {
      return 'Такого слова нет в словаре';
    }
    if (guesses.any((g) => g.map((l) => l.char).join() == word)) {
      return 'Вы уже вводили это слово';
    }

    guesses.add(_evaluate(word));
    return null;
  }

  List<Letter> _evaluate(String guess) {
    final result = List<HitType>.filled(wordLength, HitType.miss);
    final remaining = <String, int>{};

    // 1-й проход: точные совпадения.
    for (var i = 0; i < wordLength; i++) {
      if (guess[i] == answer[i]) {
        result[i] = HitType.hit;
      } else {
        remaining[answer[i]] = (remaining[answer[i]] ?? 0) + 1;
      }
    }

    // 2-й проход: буквы не на своём месте (с учётом повторов).
    for (var i = 0; i < wordLength; i++) {
      if (result[i] == HitType.hit) continue;
      final count = remaining[guess[i]] ?? 0;
      if (count > 0) {
        result[i] = HitType.partial;
        remaining[guess[i]] = count - 1;
      }
    }

    return [for (var i = 0; i < wordLength; i++) Letter(guess[i], result[i])];
  }

  /// Лучший известный статус каждой буквы (для подсказки под полем).
  Map<String, HitType> get letterStatuses {
    final map = <String, HitType>{};
    int rank(HitType t) => switch (t) {
          HitType.hit => 3,
          HitType.partial => 2,
          HitType.miss => 1,
          HitType.none => 0,
        };
    for (final guess in guesses) {
      for (final l in guess) {
        final old = map[l.char];
        if (old == null || rank(l.type) > rank(old)) {
          map[l.char] = l.type;
        }
      }
    }
    return map;
  }
}

// ---------------------------------------------------------------------------
// ПРИЛОЖЕНИЕ
// ---------------------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Слова',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Game _game = Game();

  void _newGame() {
    setState(() => _game = Game());
  }

  Future<void> _handleGuess(String guess) async {
    final error = _game.submitGuess(guess);

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error),
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }

    setState(() {});

    if (_game.state != GameState.playing) {
      await _showEndDialog();
    }
  }

  Future<void> _showEndDialog() async {
    final won = _game.state == GameState.won;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? '🎉 Победа!' : '😔 Попытки закончились'),
        content: Text(
          won
              ? 'Вы угадали слово «${_game.answer.toUpperCase()}» '
                  'за ${_game.guesses.length} из ${Game.maxAttempts} попыток.'
              : 'Загаданное слово: «${_game.answer.toUpperCase()}».',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newGame();
            },
            child: const Text('Играть снова'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playing = _game.state == GameState.playing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Слова'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Новая игра',
            icon: const Icon(Icons.refresh),
            onPressed: _newGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                spacing: 5.0,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Угадайте слово из 5 букв за 6 попыток',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  for (var i = 0; i < Game.maxAttempts; i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5.0,
                      children: [
                        for (var j = 0; j < Game.wordLength; j++)
                          if (i < _game.guesses.length)
                            Tile(
                              _game.guesses[i][j].char,
                              _game.guesses[i][j].type,
                            )
                          else
                            const Tile('', HitType.none),
                      ],
                    ),
                  const SizedBox(height: 8),
                  _UsedLetters(statuses: _game.letterStatuses),
                  GuessInput(
                    enabled: playing,
                    onSubmitGuess: _handleGuess,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ПЛИТКА С БУКВОЙ
// ---------------------------------------------------------------------------

class Tile extends StatelessWidget {
  const Tile(this.letter, this.hitType, {super.key});

  final String letter;
  final HitType hitType;

  Color get _color => switch (hitType) {
        HitType.hit => const Color(0xFF6AAA64),
        HitType.partial => const Color(0xFFC9B458),
        HitType.miss => const Color(0xFF787C7E),
        HitType.none => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    final colored = hitType != HitType.none;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _color,
        border: Border.all(
          color: colored ? _color : Colors.grey.shade400,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        letter.toUpperCase(),
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: colored ? Colors.white : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ИСПОЛЬЗОВАННЫЕ БУКВЫ (подсказка)
// ---------------------------------------------------------------------------

class _UsedLetters extends StatelessWidget {
  const _UsedLetters({required this.statuses});

  final Map<String, HitType> statuses;

  static const String _alphabet = 'абвгдежзийклмнопрстуфхцчшщъыьэюя';

  Color _bg(HitType? t) => switch (t) {
        HitType.hit => const Color(0xFF6AAA64),
        HitType.partial => const Color(0xFFC9B458),
        HitType.miss => const Color(0xFF787C7E),
        _ => Colors.grey.shade300,
      };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final ch in _alphabet.split(''))
          Container(
            width: 28,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _bg(statuses[ch]),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ch.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: statuses[ch] == null ? Colors.black87 : Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ПОЛЕ ВВОДА (по уроку «User input»: TextField + TextEditingController +
// FocusNode + IconButton + callback onSubmitGuess)
// ---------------------------------------------------------------------------

class GuessInput extends StatefulWidget {
  const GuessInput({
    super.key,
    required this.onSubmitGuess,
    this.enabled = true,
  });

  final void Function(String) onSubmitGuess;
  final bool enabled;

  @override
  State<GuessInput> createState() => _GuessInputState();
}

class _GuessInputState extends State<GuessInput> {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!widget.enabled) return;
    widget.onSubmitGuess(_textEditingController.text.trim());
    _textEditingController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              enabled: widget.enabled,
              maxLength: Game.wordLength,
              autofocus: true,
              focusNode: _focusNode,
              controller: _textEditingController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[а-яА-ЯёЁ]')),
              ],
              decoration: const InputDecoration(
                hintText: 'Введите слово',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(35)),
                ),
              ),
              onSubmitted: (_) => _onSubmit(),
            ),
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          iconSize: 40,
          icon: const Icon(Icons.arrow_circle_up),
          onPressed: widget.enabled ? _onSubmit : null,
        ),
      ],
    );
  }
}
