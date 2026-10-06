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

## Comparação com o exemplo da aula

- Mesmas dependências declaradas: Flutter, cupertino_icons e provider; flutter_test e flutter_lints para desenvolvimento.
- Mesma organização: main.dart, models, pages e providers.
- Duas páginas com componentes nativos do Flutter: Scaffold, AppBar, ListView, Card e botões.
- Navegação com Navigator.push e MaterialPageRoute.
- Estado compartilhado com ChangeNotifierProvider, context.watch e Provider.of com listen: false.
- Provider com listas em memória e notifyListeners() diretamente nas operações.
- Modelos simples, sem JSON, identificadores gerados ou persistência.

O cadastro e a edição exigem campos de texto e seleção de categoria, ausentes no e-commerce de referência. Essas são as adaptações necessárias ao CRUD pedido. Não há busca, filtros, anotações, status de aquisição, contadores, diálogos ou uma terceira página.

O SDK mínimo permanece compatível com o Flutter instalado neste computador; não foi copiada a exigência de Dart 3.13.1 da referência, pois o ambiente utiliza Dart 3.12.2.

## Interface e acessibilidade

A interface usa verde escuro e tons claros, cartões, espaçamento e hierarquia de títulos. Formulário e lista ficam lado a lado em telas largas e empilhados em telas menores.

- Textos respeitam o tamanho de fonte configurado no dispositivo.
- Botões possuem alvos de toque de pelo menos 48 pixels lógicos.
- Campos obrigatórios são identificados por texto e apresentam mensagens de erro.
- O primeiro campo inválido recebe foco; Tab permite percorrer os controles e a ação de envio do teclado salva o formulário.
- Editar leva o foco ao formulário; os botões de ação incluem o nome do livro ou da categoria em seus rótulos para leitores de tela.
- Títulos são identificados como cabeçalhos e mensagens de resultado usam regiões de anúncio de acessibilidade.
- A rolagem permite usar o formulário com teclado aberto; a animação de retorno respeita a preferência de reduzir animações.
- O tema oferece uma variante de alto contraste e a página web declara o idioma português.

Essas mudanças utilizam somente os recursos do Flutter, mantendo o CRUD, o Provider e as mesmas pastas e dependências.

## Verificação

```sh
flutter analyze
flutter test
flutter build web
```

Os quatro testes cobrem CRUD e estado compartilhado; texto a 200% com teclado aberto em tela de 320 pixels de largura; navegação por teclado; e as verificações automáticas de contraste, rótulos e tamanho dos alvos de toque do flutter_test nas duas páginas.
