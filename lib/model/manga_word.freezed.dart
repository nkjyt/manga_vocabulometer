// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'manga_word.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$MangaWordTearOff {
  const _$MangaWordTearOff();

  _MangaWord call({String? word, String? title}) {
    return _MangaWord(
      word: word,
      title: title,
    );
  }
}

/// @nodoc
const $MangaWord = _$MangaWordTearOff();

/// @nodoc
mixin _$MangaWord {
  String? get word => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MangaWordCopyWith<MangaWord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MangaWordCopyWith<$Res> {
  factory $MangaWordCopyWith(MangaWord value, $Res Function(MangaWord) then) =
      _$MangaWordCopyWithImpl<$Res>;
  $Res call({String? word, String? title});
}

/// @nodoc
class _$MangaWordCopyWithImpl<$Res> implements $MangaWordCopyWith<$Res> {
  _$MangaWordCopyWithImpl(this._value, this._then);

  final MangaWord _value;
  // ignore: unused_field
  final $Res Function(MangaWord) _then;

  @override
  $Res call({
    Object? word = freezed,
    Object? title = freezed,
  }) {
    return _then(_value.copyWith(
      word: word == freezed
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String?,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
abstract class _$MangaWordCopyWith<$Res> implements $MangaWordCopyWith<$Res> {
  factory _$MangaWordCopyWith(
          _MangaWord value, $Res Function(_MangaWord) then) =
      __$MangaWordCopyWithImpl<$Res>;
  @override
  $Res call({String? word, String? title});
}

/// @nodoc
class __$MangaWordCopyWithImpl<$Res> extends _$MangaWordCopyWithImpl<$Res>
    implements _$MangaWordCopyWith<$Res> {
  __$MangaWordCopyWithImpl(_MangaWord _value, $Res Function(_MangaWord) _then)
      : super(_value, (v) => _then(v as _MangaWord));

  @override
  _MangaWord get _value => super._value as _MangaWord;

  @override
  $Res call({
    Object? word = freezed,
    Object? title = freezed,
  }) {
    return _then(_MangaWord(
      word: word == freezed
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String?,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$_MangaWord extends _MangaWord with DiagnosticableTreeMixin {
  const _$_MangaWord({this.word, this.title}) : super._();

  @override
  final String? word;
  @override
  final String? title;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MangaWord(word: $word, title: $title)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MangaWord'))
      ..add(DiagnosticsProperty('word', word))
      ..add(DiagnosticsProperty('title', title));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _MangaWord &&
            (identical(other.word, word) ||
                const DeepCollectionEquality().equals(other.word, word)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(word) ^
      const DeepCollectionEquality().hash(title);

  @JsonKey(ignore: true)
  @override
  _$MangaWordCopyWith<_MangaWord> get copyWith =>
      __$MangaWordCopyWithImpl<_MangaWord>(this, _$identity);
}

abstract class _MangaWord extends MangaWord {
  const factory _MangaWord({String? word, String? title}) = _$_MangaWord;
  const _MangaWord._() : super._();

  @override
  String? get word => throw _privateConstructorUsedError;
  @override
  String? get title => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$MangaWordCopyWith<_MangaWord> get copyWith =>
      throw _privateConstructorUsedError;
}
