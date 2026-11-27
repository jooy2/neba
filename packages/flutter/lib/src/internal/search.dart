/// What "this matches what I typed" means: a text with its accents folded
/// away, so `jose` finds `José`, as the React package's `internal/search.ts`
/// folds it.
///
/// The React package folds with `String.prototype.normalize('NFD')` and drops
/// the combining marks it splits off. Dart has no normalization, so the fold
/// is that same result written out as a table for the scripts whose letters
/// carry accents, Latin, Greek and Cyrillic, from Unicode 17's canonical
/// decompositions, and a combining mark from U+0300 to U+036F on its own is
/// dropped as the React package drops it. A character outside the table is
/// compared as it is written; a Hangul syllable, which `NFD` would take apart
/// and put back together, is one of them, and a query never marks half of one.
///
/// The library talking to itself: nothing here is exported.
library;

/// Each accented character, and at the same index in [_bare] the letter it
/// folds to.
const String _accented =
    'ÀÁÂÃÄÅÇÈÉÊËÌÍÎÏÑÒÓÔÕÖÙÚÛÜÝàáâãäåçèéêëìíî'
    'ïñòóôõöùúûüýÿĀāĂăĄąĆćĈĉĊċČčĎďĒēĔĕĖėĘęĚěĜ'
    'ĝĞğĠġĢģĤĥĨĩĪīĬĭĮįİĴĵĶķĹĺĻļĽľŃńŅņŇňŌōŎŏŐő'
    'ŔŕŖŗŘřŚśŜŝŞşŠšŢţŤťŨũŪūŬŭŮůŰűŲųŴŵŶŷŸŹźŻżŽ'
    'žƠơƯưǍǎǏǐǑǒǓǔǕǖǗǘǙǚǛǜǞǟǠǡǢǣǦǧǨǩǪǫǬǭǮǯǰǴǵ'
    'ǸǹǺǻǼǽǾǿȀȁȂȃȄȅȆȇȈȉȊȋȌȍȎȏȐȑȒȓȔȕȖȗȘșȚțȞȟȦȧ'
    'ȨȩȪȫȬȭȮȯȰȱȲȳʹ;΅Ά·ΈΉΊΌΎΏΐΪΫάέήίΰϊϋόύώϓϔЀЁ'
    'ЃЇЌЍЎЙйѐёѓїќѝўѶѷӁӂӐӑӒӓӖӗӚӛӜӝӞӟӢӣӤӥӦӧӪӫӬӭ'
    'ӮӯӰӱӲӳӴӵӸӹḀḁḂḃḄḅḆḇḈḉḊḋḌḍḎḏḐḑḒḓḔḕḖḗḘḙḚḛḜḝ'
    'ḞḟḠḡḢḣḤḥḦḧḨḩḪḫḬḭḮḯḰḱḲḳḴḵḶḷḸḹḺḻḼḽḾḿṀṁṂṃṄṅ'
    'ṆṇṈṉṊṋṌṍṎṏṐṑṒṓṔṕṖṗṘṙṚṛṜṝṞṟṠṡṢṣṤṥṦṧṨṩṪṫṬṭ'
    'ṮṯṰṱṲṳṴṵṶṷṸṹṺṻṼṽṾṿẀẁẂẃẄẅẆẇẈẉẊẋẌẍẎẏẐẑẒẓẔẕ'
    'ẖẗẘẙẛẠạẢảẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặẸẹẺẻẼẽẾếỀềỂ'
    'ểỄễỆệỈỉỊịỌọỎỏỐốỒồỔổỖỗỘộỚớỜờỞởỠỡỢợỤụỦủỨứỪ'
    'ừỬửỮữỰựỲỳỴỵỶỷỸỹἀἁἂἃἄἅἆἇἈἉἊἋἌἍἎἏἐἑἒἓἔἕἘἙἚ'
    'ἛἜἝἠἡἢἣἤἥἦἧἨἩἪἫἬἭἮἯἰἱἲἳἴἵἶἷἸἹἺἻἼἽἾἿὀὁὂὃὄ'
    'ὅὈὉὊὋὌὍὐὑὒὓὔὕὖὗὙὛὝὟὠὡὢὣὤὥὦὧὨὩὪὫὬὭὮὯὰάὲέὴ'
    'ήὶίὸόὺύὼώᾀᾁᾂᾃᾄᾅᾆᾇᾈᾉᾊᾋᾌᾍᾎᾏᾐᾑᾒᾓᾔᾕᾖᾗᾘᾙᾚᾛᾜᾝᾞ'
    'ᾟᾠᾡᾢᾣᾤᾥᾦᾧᾨᾩᾪᾫᾬᾭᾮᾯᾰᾱᾲᾳᾴᾶᾷᾸᾹᾺΆᾼι῁ῂῃῄῆῇῈΈῊΉ'
    'ῌ῍῎῏ῐῑῒΐῖῗῘῙῚΊ῝῞῟ῠῡῢΰῤῥῦῧῨῩῪΎῬ῭΅`ῲῳῴῶῷῸΌ'
    'ῺΏῼ´';

const String _bare =
    'AAAAAACEEEEIIIINOOOOOUUUUYaaaaaaceeeeiii'
    'inooooouuuuyyAaAaAaCcCcCcCcDdEeEeEeEeEeG'
    'gGgGgGgHhIiIiIiIiIJjKkLlLlLlNnNnNnOoOoOo'
    'RrRrRrSsSsSsSsTtTtUuUuUuUuUuUuWwYyYZzZzZ'
    'zOoUuAaIiOoUuUuUuUuUuAaAaÆæGgKkOoOoƷʒjGg'
    'NnAaÆæØøAaAaEeEeIiIiOoOoRrRrUuUuSsTtHhAa'
    'EeOoOoOoOoYyʹ;¨Α·ΕΗΙΟΥΩιΙΥαεηιυιυουωϒϒЕЕ'
    'ГІКИУИиеегікиуѴѵЖжАаАаЕеӘәЖжЗзИиИиОоӨөЭэ'
    'УуУуУуЧчЫыAaBbBbBbCcDdDdDdDdDdEeEeEeEeEe'
    'FfGgHhHhHhHhHhIiIiKkKkKkLlLlLlLlMmMmMmNn'
    'NnNnNnOoOoOoOoPpPpRrRrRrRrSsSsSsSsSsTtTt'
    'TtTtUuUuUuUuUuVvVvWwWwWwWwWwXxXxYyZzZzZz'
    'htwyſAaAaAaAaAaAaAaAaAaAaAaAaEeEeEeEeEeE'
    'eEeEeIiIiOoOoOoOoOoOoOoOoOoOoOoOoUuUuUuU'
    'uUuUuUuYyYyYyYyααααααααΑΑΑΑΑΑΑΑεεεεεεΕΕΕ'
    'ΕΕΕηηηηηηηηΗΗΗΗΗΗΗΗιιιιιιιιΙΙΙΙΙΙΙΙοοοοο'
    'οΟΟΟΟΟΟυυυυυυυυΥΥΥΥωωωωωωωωΩΩΩΩΩΩΩΩααεεη'
    'ηιιοουυωωααααααααΑΑΑΑΑΑΑΑηηηηηηηηΗΗΗΗΗΗΗ'
    'ΗωωωωωωωωΩΩΩΩΩΩΩΩαααααααΑΑΑΑΑι¨ηηηηηΕΕΗΗ'
    'Η᾿᾿᾿ιιιιιιΙΙΙΙ῾῾῾υυυυρρυυΥΥΥΥΡ¨¨`ωωωωωΟΟ'
    'ΩΩΩ´';

Map<int, int>? _folds;

/// The table as code units, built the first time a text is folded.
Map<int, int> get _table {
  return _folds ??= <int, int>{
    for (int i = 0; i < _accented.length; i++) _accented.codeUnitAt(i): _bare.codeUnitAt(i),
  };
}

bool _combining(int unit) => unit >= 0x0300 && unit <= 0x036F;

/// [text] with its accents folded away, the letters otherwise as written.
String nebaFold(String text) {
  final Map<int, int> table = _table;
  final StringBuffer folded = StringBuffer();

  for (final int unit in text.codeUnits) {
    if (!_combining(unit)) {
      folded.writeCharCode(table[unit] ?? unit);
    }
  }

  return folded.toString();
}

/// A value as something a query is matched against: folded and lower-cased,
/// so `jose` finds `José` and `SEOUL` finds `Seoul`. Anything but a string, a
/// number or a boolean is nothing to match.
String nebaSearchText(Object? value) {
  if (value is String || value is num || value is bool) {
    return nebaFold(value.toString()).toLowerCase();
  }

  return '';
}

/// A text with its accents folded, and where each folded unit came from, so
/// a match found in [text] can be marked in the original.
class NebaFoldedText {
  const NebaFoldedText._(this.text, this.starts, this.ends);

  /// The folded text.
  final String text;

  /// For every code unit of [text], where its character starts in the
  /// original.
  final List<int> starts;

  /// And where it ends there, past any combining mark that followed it.
  final List<int> ends;
}

/// [text] folded with the way back to it, or `null` when there is nothing in
/// it to fold, which is true of nearly every string.
NebaFoldedText? nebaFoldText(String text) {
  final Map<int, int> table = _table;
  bool changes = false;

  for (final int unit in text.codeUnits) {
    if (_combining(unit) || table.containsKey(unit)) {
      changes = true;
      break;
    }
  }

  if (!changes) {
    return null;
  }

  final StringBuffer folded = StringBuffer();
  final List<int> starts = <int>[];
  final List<int> ends = <int>[];

  for (int index = 0; index < text.length; index++) {
    final int unit = text.codeUnitAt(index);

    if (_combining(unit)) {
      // A combining mark on its own belongs to the letter before it.
      for (int at = ends.length - 1; at >= 0 && ends[at] == index; at--) {
        ends[at] = index + 1;
      }
    } else {
      starts.add(index);
      ends.add(index + 1);
      folded.writeCharCode(table[unit] ?? unit);
    }
  }

  return NebaFoldedText._(folded.toString(), starts, ends);
}
