import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:livrete2000/main.dart';
import 'package:livrete2000/models/book.dart';
import 'package:livrete2000/models/category.dart';
import 'package:livrete2000/providers/wishlist_provider.dart';

Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 40,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> openApp(WidgetTester tester, WishlistProvider wishlist) async {
  await tester.pumpWidget(
    ChangeNotifierProvider.value(value: wishlist, child: const LivreteApp()),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('CRUD nas duas páginas mantém o estado compartilhado', (
    tester,
  ) async {
    final wishlist = WishlistProvider();
    var notifications = 0;
    wishlist.addListener(() => notifications++);
    await openApp(tester, wishlist);
    await tapVisible(tester, find.text('Adicionar livro'));
    expect(wishlist.books, isEmpty);
    expect(find.text('Informe o título do livro.'), findsOneWidget);
    expect(find.text('Informe o nome do autor.'), findsOneWidget);
    await tapVisible(tester, find.byTooltip('Categorias'));
    await tapVisible(tester, find.text('Adicionar categoria'));
    expect(wishlist.categories, isEmpty);
    expect(find.text('Informe o nome da categoria.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Fantasia');
    await tapVisible(tester, find.text('Adicionar categoria'));
    expect(wishlist.categories.single.name, 'Fantasia');
    await tapVisible(tester, find.byTooltip('Voltar à lista de desejos'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'O Hobbit');
    await tester.enterText(find.byType(TextField).at(1), 'Tolkien');
    await tapVisible(tester, find.byType(DropdownButton<BookCategory>));
    await tester.tap(find.text('Fantasia').last);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Adicionar livro'));
    expect(find.text('O Hobbit'), findsOneWidget);
    expect(find.text('Tolkien • Fantasia'), findsOneWidget);
    await tapVisible(tester, find.byTooltip('Editar livro'));
    await tester.enterText(find.byType(TextField).at(0), 'O Senhor dos Anéis');
    await tapVisible(tester, find.text('Salvar livro'));
    expect(find.text('O Hobbit'), findsNothing);
    expect(find.text('O Senhor dos Anéis'), findsOneWidget);
    await tapVisible(tester, find.byTooltip('Categorias'));
    await tapVisible(tester, find.byTooltip('Editar categoria'));
    await tester.enterText(find.byType(TextField), 'Literatura');
    await tapVisible(tester, find.text('Salvar categoria'));
    await tapVisible(tester, find.byTooltip('Voltar à lista de desejos'));
    await tester.pumpAndSettle();
    expect(find.text('Tolkien • Literatura'), findsOneWidget);
    await tapVisible(tester, find.byTooltip('Editar livro'));
    await tapVisible(tester, find.byTooltip('Categorias'));
    await tapVisible(tester, find.byTooltip('Excluir categoria'));
    expect(wishlist.categories, isEmpty);
    expect(wishlist.books.single.category, isNull);
    await tapVisible(tester, find.byTooltip('Voltar à lista de desejos'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Tolkien • Sem categoria'));
    expect(find.text('Tolkien • Sem categoria'), findsOneWidget);
    await tapVisible(tester, find.text('Salvar livro'));
    await tapVisible(tester, find.byTooltip('Editar livro'));
    await tapVisible(tester, find.byTooltip('Excluir livro'));
    expect(wishlist.books, isEmpty);
    expect(find.text('Salvar livro'), findsNothing);
    expect(notifications, 7);
    expect(tester.takeException(), isNull);
  });

  testWidgets('texto a 200% e teclado aberto não causam estouro de layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final wishlist = WishlistProvider();
    final category = BookCategory(
      name: 'Literatura brasileira e histórias contemporâneas',
    );
    wishlist.addCategory(category);
    wishlist.addBook(
      Book(
        title: 'Uma história muito longa para a próxima leitura',
        author: 'Um autor de nome completo',
        category: category,
      ),
    );
    await openApp(tester, wishlist);
    await tapVisible(tester, find.byTooltip('Editar livro'));
    await tapVisible(tester, find.text('Salvar livro'));
    expect(tester.takeException(), isNull);
    await tapVisible(tester, find.byTooltip('Categorias'));
    await tapVisible(tester, find.byTooltip('Editar categoria'));
    await tapVisible(tester, find.text('Salvar categoria'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('navegação por teclado e envio do formulário', (tester) async {
    final wishlist = WishlistProvider();
    await openApp(tester, wishlist);
    await tapVisible(tester, find.byType(TextField).first);
    await tester.enterText(
      find.byType(TextField).first,
      'Leitura pelo teclado',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byType(TextField).at(1))
          .focusNode!
          .hasFocus,
      isTrue,
    );
    await tester.enterText(find.byType(TextField).at(1), 'Autor');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(wishlist.books.single.title, 'Leitura pelo teclado');
    expect(tester.takeException(), isNull);
  });

  testWidgets('contraste, rótulos e alvos de toque nas duas páginas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    final wishlist = WishlistProvider();
    final category = BookCategory(name: 'Fantasia');
    wishlist.addCategory(category);
    wishlist.addBook(
      Book(title: 'O Hobbit', author: 'Tolkien', category: category),
    );
    await openApp(tester, wishlist);
    expect(
      find.bySemanticsLabel(RegExp('Editar livro O Hobbit')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('O Hobbit'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await tapVisible(tester, find.byTooltip('Categorias'));
    expect(
      find.bySemanticsLabel(RegExp('Excluir categoria Fantasia')),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Fantasia'), findsOneWidget);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}
