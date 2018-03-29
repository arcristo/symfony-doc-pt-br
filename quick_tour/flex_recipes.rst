Flex: Componha sua Aplicação
============================

Depois de ler a primeira parte deste tutorial, você decidiu que o Symfony
valia mais 10 minutos. Ótima escolha! Nesta segunda parte, você aprenderá sobre
o Symfony Flex: a incrível ferramenta que torna a adição de novos recursos tão simples quanto executar
um comando. Ele é também a razão pela qual o Symfony é ideal para um pequeno microsserviço
ou uma enorme aplicação. Curioso? Perfeito!

Symfony: Comece Micro!
----------------------

A menos que você esteja criando uma API pura (mais sobre isso em breve!), provavelmente você desejará
renderizar HTML. Para fazer isso, você usará o `Twig`_. O Twig é uma engine de template flexível,
rápida e segura para PHP. Ele torna seus templates mais legíveis e concisos; também
os torna mais amigáveis para web designers.

O Twig já está instalado na nossa aplicação? Na verdade, ainda não! E isso é ótimo!
Quando você inicia um novo projeto Symfony, ele é *pequeno*: apenas as dependências mais críticas
estão incluídas no seu arquivo ``composer.json``:

.. code-block:: text

    "require": {
        "...",
        "symfony/console": "^4.1",
        "symfony/flex": "^1.0",
        "symfony/framework-bundle": "^4.1",
        "symfony/yaml": "^4.1"
    }

Isso torna o Symfony diferente de qualquer outro framework PHP! Em vez de começar com
uma aplicação *volumosa* com *todos* os recursos possíveis que você possa precisar, uma aplicação Symfony é
pequena, simples e *rápida*. E você tem total controle sobre o que adiciona.

Receitas do Flex e Aliases
--------------------------

Então, como podemos instalar e configurar o Twig? Apenas execute um comando:

.. code-block:: terminal

    $ composer require twig

Duas coisas *muito* interessantes acontecem nos bastidores graças ao Symfony Flex: um
plugin do Composer que já está instalado em nosso projeto.

Primeiro, ``twig`` não é o nome de um pacote do Composer: é um *alias* do Flex que
aponta para ``symfony/twig-bundle``. O Flex resolve esse alias para o Composer.

E segundo, o Flex instala uma *receita* para o ``symfony/twig-bundle``. O que é uma receita?
É uma maneira de uma biblioteca se configurar automaticamente adicionando e modificando
arquivos. Graças a receitas, a adição de recursos é perfeita e automatizada: instale um pacote
e pronto!

Você pode encontrar uma lista completa de receitas e aliases acessando `https://symfony.sh`_.

O que essa receita fez? Além de ativar automaticamente o recurso em
``config/bundles.php``, ela adicionou 3 coisas:

``config/packages/twig.yaml``
    Um arquivo de configuração que configura o Twig com padrões sensatos.

``config/routes/dev/twig.yaml``
    Uma rota que ajuda você a depurar suas páginas de erro.

``templates/``
    Este é o diretório onde os arquivos de template irão ficar. A receita também adicionou
    um arquivo de layout ``base.html.twig``.

Twig: Renderizando um Template
------------------------------

Graças ao Flex, após um comando, você pode começar a usar o Twig imediatamente:

.. code-block:: diff

    // src/Controller/DefaultController.php
    // ...

    + use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

    -class DefaultController
    +class DefaultController extends AbstractController
     {
         /**
          * @Route("/hello/{name}")
          */
         public function index($name)
         {
    -        return new Response("Olá $name!");
    +        return $this->render('default/index.html.twig', [
    +            'name' => $name,
    +        ]);
         }

Ao estender ``AbstractController``, você agora tem acesso a vários métodos
e ferramentas de atalho, como ``render()``. Crie o novo template:

.. code-block:: twig

    {# templates/default/index.html.twig #}
    <h1>Olá {{ name }}</h1>

É isso aí! A sintaxe ``{{ name }}`` irá imprimir a variável ``name`` que é passada
do controller. Se você é novo no Twig, seja bem-vindo! Você aprenderá mais sobre
sua sintaxe e poder mais tarde.

Mas, agora, a página contém *apenas* a tag ``h1``. Para dar a ela um layout HTML,
estenda ``base.html.twig``:

.. code-block:: twig

    {# templates/default/index.html.twig #}
    {% extends 'base.html.twig' %}

    {% block body %}
        <h1>Olá {{ name }}</h1>
    {% endblock %}

Isso é chamado de herança de template: nossa página agora herda a estrutura HTML de
``base.html.twig``.

Profiler: Paraíso da Depuração
------------------------------

Um dos recursos mais *legais* do Symfony ainda não está instalado! Vamos consertar isso:

.. code-block:: terminal

    $ composer require profiler

Sim! Este é outro alias! E o Flex *também* instala outra receita, que automatiza
a configuração do Profiler do Symfony. Qual o resultado? Atualize!

Vê aquela barra preta na parte inferior da página? Essa é a barra de ferramentas de depuração web, e é sua nova
melhor amiga. Ao passar o mouse sobre cada ícone, você pode obter informações sobre qual controller
foi executado, informações de desempenho, acertos e erros de cache e muito mais. Clique em
qualquer ícone para ir para o *profiler* onde você tem dados de depuração e desempenho
ainda *mais* detalhados!

Ah, e quando você instalar mais bibliotecas, você obterá mais ferramentas (como um ícone da barra de ferramentas de depuração
web que mostra as consultas ao banco de dados).

Usar o profiler é fácil porque ele *se* configurou graças à receita.
O que mais podemos instalar tão facilmente?

Suporte a API Rica
------------------

Você está criando uma API? Você já pode retornar JSON facilmente de qualquer controller::

    /**
     * @Route("/api/hello/{name}")
     */
    public function apiExample($name)
    {
        return $this->json([
            'name' => $name,
            'symfony' => 'rocks',
        ]);
    }

Mas para uma API *verdadeiramente* rica, tente instalar a `Api Platform`_:

.. code-block:: terminal

    $ composer require api

Esse é um alias para ``api-platform/api-pack``, que tem dependências de vários
outros pacotes, como os componentes Validator e Security do Symfony, assim como o Doctrine
ORM. Na verdade o Flex instalou *5* receitas!

Mas, como de custome, podemos começar imediatamente a usar a nova biblioteca. Quer criar uma
API rica para uma tabela ``product``? Crie uma entidade ``Product`` e adicione a
annotation ``@ApiResource()``::

    // src/Entity/Product.php
    // ...

    use ApiPlatform\Core\Annotation\ApiResource;
    use Doctrine\ORM\Mapping as ORM;

    /**
     * @ORM\Entity()
     * @ApiResource()
     */
    class Product
    {
        /**
         * @ORM\Id
         * @ORM\GeneratedValue(strategy="AUTO")
         * @ORM\Column(type="integer")
         */
        private $id;

        /**
         * @ORM\Column(type="string")
         */
        private $name;

        /**
         * @ORM\Column(type="string")
         */
        private $price;

        // ...
    }

Feito! Você agora tem endpoints para listar, adicionar, atualizar e excluir produtos! Não acredita em
mim? Liste suas rotas executando:

.. code-block:: terminal

    $ php bin/console debug:router

.. code-block:: text

    ------------------------------ -------- -------------------------------------
     Name                           Method   Path
    ------------------------------ -------- -------------------------------------
     api_products_get_collection    GET      /api/products.{_format}
     api_products_post_collection   POST     /api/products.{_format}
     api_products_get_item          GET      /api/products/{id}.{_format}
     api_products_put_item          PUT      /api/products/{id}.{_format}
     api_products_delete_item       DELETE   /api/products/{id}.{_format}
     ...
    ------------------------------ -------- -------------------------------------

Remova Receitas Facilmente
--------------------------

Ainda não está convencido? Não tem problema: remova a biblioteca:

.. code-block:: terminal

    $ composer remove api

O Flex irá *desinstalar* as receitas: removendo arquivos e desfazendo alterações para retornar sua
aplicação ao seu estado original. Experimente sem se preocupar.

Mais Recursos, Arquitetura e Velocidade
---------------------------------------

Espero que você esteja tão animado com o Flex quanto eu! Mas ainda temos mais *um* capítulo,
e é o mais importante. Eu quero mostrar a você como o Symfony permite que você construa
recursos rapidamente *sem* sacrificar a qualidade do código ou o desempenho. A base de tudo é
o container de serviços, e ele é o superpoder do Symfony. Leia mais: sobre :doc:`/quick_tour/the_architecture`.

.. _`https://symfony.sh`: https://symfony.sh
.. _`Api Platform`: https://api-platform.com/
.. _`Twig`: https://twig.symfony.com/
