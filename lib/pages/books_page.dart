import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../providers/wishlist_provider.dart';
import 'categories_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});
  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _titleFocus = FocusNode();
  final _authorFocus = FocusNode();
  final _scroll = ScrollController();
  Book? _editing;
  BookCategory? _category;
  String? _titleError, _authorError, _status;

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    _titleFocus.dispose();
    _authorFocus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _clear() {
    _title.clear();
    _author.clear();
    setState(() {
      _editing = null;
      _category = null;
      _titleError = null;
      _authorError = null;
    });
  }

  void _save(WishlistProvider wishlist) {
    final title = _title.text.trim();
    final author = _author.text.trim();
    setState(() {
      _titleError = title.isEmpty ? 'Informe o título do livro.' : null;
      _authorError = author.isEmpty ? 'Informe o nome do autor.' : null;
      _status = null;
    });
    if (_titleError != null || _authorError != null) {
      (_titleError != null ? _titleFocus : _authorFocus).requestFocus();
      return;
    }
    final category = wishlist.categories.contains(_category) ? _category : null;
    final editing = _editing != null;
    if (editing) {
      wishlist.editBook(_editing!, title, author, category);
    } else {
      wishlist.addBook(Book(title: title, author: author, category: category));
    }
    _clear();
    setState(
      () => _status = editing
          ? 'Livro atualizado.'
          : 'Livro adicionado à sua lista.',
    );
    _titleFocus.requestFocus();
  }

  void _edit(Book book) {
    _title.text = book.title;
    _author.text = book.author;
    setState(() {
      _editing = book;
      _category = book.category;
      _titleError = null;
      _authorError = null;
      _status = null;
    });
    if (_scroll.hasClients) {
      _scroll.animateTo(
        0,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    _titleFocus.requestFocus();
  }

  Widget _form(WishlistProvider wishlist) {
    final theme = Theme.of(context);
    final category = wishlist.categories.contains(_category) ? _category : null;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Card(
        semanticContainer: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  _editing == null ? 'Um novo desejo' : 'Editar seu desejo',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Título e autor são obrigatórios. A categoria é opcional.',
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _title,
                focusNode: _titleFocus,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _authorFocus.requestFocus(),
                onChanged: (_) {
                  if (_titleError != null) setState(() => _titleError = null);
                },
                decoration: InputDecoration(
                  labelText: 'Título (obrigatório)',
                  errorText: _titleError,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _author,
                focusNode: _authorFocus,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(wishlist),
                onChanged: (_) {
                  if (_authorError != null) setState(() => _authorError = null);
                },
                decoration: InputDecoration(
                  labelText: 'Autor (obrigatório)',
                  errorText: _authorError,
                ),
              ),
              const SizedBox(height: 18),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Categoria (opcional)',
                ),
                child: DropdownButtonHideUnderline(
                  child: Semantics(
                    label: 'Categoria do livro',
                    child: DropdownButton<BookCategory>(
                      value: category,
                      isExpanded: true,
                      itemHeight: null,
                      hint: const Text('Sem categoria'),
                      borderRadius: BorderRadius.circular(12),
                      items: [
                        const DropdownMenuItem<BookCategory>(
                          value: null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('Sem categoria'),
                          ),
                        ),
                        for (final item in wishlist.categories)
                          DropdownMenuItem(
                            value: item,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(item.name),
                            ),
                          ),
                      ],
                      onChanged: (value) => setState(() => _category = value),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _save(wishlist),
                icon: Icon(_editing == null ? Icons.add : Icons.check),
                label: Text(
                  _editing == null ? 'Adicionar livro' : 'Salvar livro',
                ),
              ),
              if (_editing != null) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    _clear();
                    setState(() => _status = 'Edição cancelada.');
                    _titleFocus.requestFocus();
                  },
                  child: const Text('Cancelar'),
                ),
              ],
              if (_status != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    _status!,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _collection(WishlistProvider wishlist) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Sua lista de desejos',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          const Text('As histórias que você quer conhecer.'),
          const SizedBox(height: 20),
          if (wishlist.books.isEmpty)
            Card(
              semanticContainer: false,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.auto_stories_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Espaço para a próxima história',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicione seu primeiro livro pelo formulário.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          for (final book in wishlist.books) ...[
            Card(
              semanticContainer: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        book.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${book.author} • ${book.category?.name ?? "Sem categoria"}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Tooltip(
                          message: 'Editar livro',
                          child: OutlinedButton.icon(
                            onPressed: () => _edit(book),
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(
                              'Editar',
                              semanticsLabel: 'Editar livro ${book.title}',
                            ),
                          ),
                        ),
                        Tooltip(
                          message: 'Excluir livro',
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                            onPressed: () {
                              wishlist.removeBook(book);
                              if (_editing == book) _clear();
                              setState(
                                () => _status = 'Livro ${book.title} excluído.',
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: Text(
                              'Excluir',
                              semanticsLabel: 'Excluir livro ${book.title}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final theme = Theme.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final navigationBelow =
        MediaQuery.sizeOf(context).width < 420 || textScaler.scale(16) > 20;
    final navigationHeight = textScaler.scale(20) + 52;
    final categoriesButton = Tooltip(
      message: 'Categorias',
      child: OutlinedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoriesPage()),
          );
        },
        child: const Text('Categorias'),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livrete'),
        actions: navigationBelow
            ? null
            : [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: categoriesButton,
                ),
              ],
        bottom: navigationBelow
            ? PreferredSize(
                preferredSize: Size.fromHeight(navigationHeight),
                child: SizedBox(
                  height: navigationHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: categoriesButton,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 850;
                return FocusTraversalGroup(
                  child: ListView(
                    controller: _scroll,
                    padding: EdgeInsets.all(
                      constraints.maxWidth < 500 ? 16 : 32,
                    ),
                    children: [
                      Card(
                        semanticContainer: false,
                        color: theme.colorScheme.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SUA ESTANTE DO FUTURO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Semantics(
                                header: true,
                                child: Text(
                                  'Toda leitura começa com um desejo.',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Guarde os livros que você quer ler e organize suas próximas histórias.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _form(wishlist)),
                            const SizedBox(width: 28),
                            Expanded(flex: 6, child: _collection(wishlist)),
                          ],
                        )
                      else ...[
                        _form(wishlist),
                        const SizedBox(height: 28),
                        _collection(wishlist),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
