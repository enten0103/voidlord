import 'package:voidlord/tono_reader/model/base/tono_location.dart';
import 'package:voidlord/tono_reader/model/tono_book_mark.dart';
import 'package:voidlord/tono_reader/model/tono_book_note.dart';

class BookReaderInfo {
  final String bookHash;

  TonoLocation? histroy;
  List<TonoBookMark> bookMarks;
  List<TonoBookNote> bookNotes;

  BookReaderInfo({
    required this.bookHash,
    this.histroy,
    required this.bookMarks,
    required this.bookNotes,
  });
}
