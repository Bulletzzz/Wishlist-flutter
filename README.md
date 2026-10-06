# Livrete

Lista de desejos de livros feita com Flutter e Provider, seguindo a organização do ecommerce_turmab.

## Executar

```sh
flutter pub get
flutter run -d chrome
```

Os dados ficam em memória e são reiniciados ao fechar o aplicativo. Não há dependências de plugins nativos ou exigência de suporte a links simbólicos. Para compilar para Windows, são necessárias as ferramentas de desenvolvimento desktop do Visual Studio.

## Estrutura

```text
lib/
  main.dart
  models/
    book.dart
    category.dart
  pages/
    books_page.dart
    categories_page.dart
  providers/
    wishlist_provider.dart
```

As duas páginas permitem adicionar, listar, editar e excluir livros e categorias. Um livro contém título, autor e categoria opcional. Excluir uma categoria mantém seus livros como “Sem categoria”. Campos obrigatórios vazios não são cadastrados.

