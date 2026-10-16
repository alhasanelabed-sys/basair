import 'package:flutter_test/flutter_test.dart';
import 'package:basair/snapshot.dart';
void main() {
  test('preserves private notes and known journey progress', () {
    final value = validateSnapshot({'favorites':['21:30'], 'notes':[{'id':'n', 'body':'تأمل شخصي','verseId':'21:30','updatedAt':'2026-10-15'}], 'progress':{'water':2}});
    expect(value['favorites'], ['21:30']);
    expect(value['notes'][0]['body'], 'تأمل شخصي');
    expect(value['progress']['water'], 2);
  });
  test('rejects unsafe verse references and broken notes', () {
    expect(() => validateSnapshot({'favorites':['../../x'], 'notes':[]}), throwsFormatException);
    expect(() => validateSnapshot({'favorites':[], 'notes':[{'id':'n','body':'ا' * 10001}]}), throwsFormatException);
  });
  test('does not store unexpected fields', () {
    final value = validateSnapshot({'favorites':[],'notes':[],'unexpected':'ignore'});
    expect(value.containsKey('unexpected'), false);
  });
  test('rejects newer schema and duplicate IDs before replacement', () {
    expect(() => validateSnapshot({'version':2,'favorites':[],'notes':[]}), throwsFormatException);
    expect(() => validateSnapshot({'version':1,'favorites':[],'notes':[{'id':'same','body':'first'},{'id':'same','body':'second'}]}), throwsFormatException);
  });
}
