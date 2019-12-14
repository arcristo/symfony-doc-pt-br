Flex: Componha sua Aplicação
============================

Depois de ler a primeira parte deste tutorial, você decidiu que o Symfony
vale mais 10 minutos. Ótima escolha! Nesta segunda parte, você aprenderá sobre
o Symfony Flex: a incrível ferramenta que torna a adição de novos recursos tão simples quanto executar
um comando. Ele também é a razão pela qual o Symfony é ideal para um pequeno microsserviço
ou uma enorme aplicação. Curiosa? Perfeito!

Symfony: Comece Micro!
----------------------

A menos que você esteja criando uma API pura (falaremos mais sobre isso em breve!), você provavelmente desejará
renderizar HTML. Para fazer isso você usará o `Twig`_. Twig é um motor de template para PHP
flexível, rápido e seguro. Ele torna seus templates mais legíveis e concisos; ele também
os torna mais amigáveis para web designers.

O Twig já está instalado em nossa aplicação? Na verdade, ainda não! E isso é ótimo!
Quando você inicia um novo projeto Symfony, ele é *pequeno*: apenas as dependências mais críticas
são incluídas no seu arquivo ``composer.json``:

.. code-block:: text

    "require": {
        "...",
        "symfony/console": "^4.1",
        "symfony/flex": "^1.0",
        "symfony/framework-bundle": "^4.1",
        "symfony/yaml": "^4.1"
    }

Isso torna o Symfony diferente de qualquer outro framework PHP! Em vez de começar com
uma aplicação *volumosa* com *todos* os recursos que você possa vir a precisar, uma aplicação Symfony é
pequena, simples e *rápida*. E você tem total controle sobre o que adicionar.

Receitas e Aliases do Flex
--------------------------

Então, como podemos instalar e configurar o Twig? Executando um único comando:

.. code-block:: terminal

    $ composer require twig

Duas coisas *muito* interessantes acontecem nos bastidores graças ao Symfony Flex: um
plug-in do Composer que já está instalado em nosso projeto.

Primeiro, ``twig`` não é o nome de um pacote do Composer: é um *alias* do Flex que
aponta para ``symfony/twig-bundle``. O Flex converte esse alias para o Composer.

E segundo, o Flex instala uma *receita* para ``symfony/twig-bundle``. O que é uma receita?
É uma maneira de uma biblioteca se configurar automaticamente adicionando e modificando
arquivos. Graças às receitas a adicão de recursos é tranquila e automatizada: instale um pacote
e pronto!

Você pode encontrar uma lista completa de receitas e aliases acessando `https://flex.symfony.com`_.

O que esta receita fez? Além de ativar automaticamente o recurso em
``config/bundles.php``, ela adicionou 3 coisas:

``config/packages/twig.yaml``
    Um arquivo de configuração que configura o Twig com padrões sensatos.

``config/routes/dev/twig.yaml``
    Uma rota que te ajuda a depurar suas páginas de erro.

``templates/``
    Este é o diretório onde os arquivos de template irão ficar. A receita também adicionou
    um arquivo de layout ``base.html.twig``.

Twig: Renderizando um Template
------------------------------

Graças ao Flex, após um comando você pode começar a usar o Twig imediatamente:

.. code-block:: diff

    // src/Controller/DefaultController.php
    namespace App\Controller;

    use Symfony\Component\Routing\Annotation\Route;
    - use Symfony\Component\HttpFoundation\Response;
    + use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

    -class DefaultController
    +class DefaultController extends AbstractController
     {
         /**
          * @Route("/hello/{name}")
          */
         public function index($name)
         {
    -        return new Response("Olá, $name!");
    +        return $this->render('default/index.html.twig', [
    +            'name' => $name,
    +        ]);
         }
    }

Ao extender ``AbstractController``, você agora tem acesso a vários métodos de
atalhos e ferramentas, como ``render()``. Crie um novo template:

.. code-block:: html+twig

    {# templates/default/index.html.twig #}
    <h1>Olá, {{ name }}</h1>

É isso aí! A sintaxe ``{{ name }}`` irá imprimir a variável ``name`` que é passada
a partir do controlador. Se você é nova no Twig, seja bem-vinda! Você aprenderá mais sobre
sua sintaxe e poder posteriormente.

Mas, por enquanto, a página contém *apenas* a tag ``h1``. Para dar a ela um layout HTML,
extenda ``base.html.twig``:

.. code-block:: html+twig

    {# templates/default/index.html.twig #}
    {% extends 'base.html.twig' %}

    {% block body %}
        <h1>Olá, {{ name }}</h1>
    {% endblock %}

Isso é chamado de herança de template: nossa página agora herda a estrutura HTML de
``base.html.twig``.

Profiler: Paraíso da Depuração
------------------------------

Um dos recursos *mais legais* do Symfony ainda nem está instalado! Vamos consertar isso:

.. code-block:: terminal

    $ composer require profiler

Sim! Este é outro alias! E o Flex *também* instala outra receita, que automatiza
a configuração do Profiler do Symfony. Qual o resultado? Recarregue a página!

Vê aquela barra preta no final da página? Essa é a barra de ferramentas de depuração web, e é sua nova
melhor amiga. Ao passar o mouse sobre cada ícone você pode obter informações sobre qual controlador
foi executado, informações de performance, itens encontrados ou não em cache e muito mais. Clique em
qualquer ícone para acessar o *profiler*, onde você tem dados de depuração e performance
*ainda mais* detalhados!

Ah, e à medida que você instala mais bibliotecas, você obtém mais ferramentas (como um ícone da barra de ferramentas de depuração
web que mostra consultas ao banco de dados).

Agora você pode usar diretamente o profiler porque ele *se* configurou graças à
receita. O que mais podemos instalar?

Suporte a API Rica
------------------

Você está construindo uma API? Você já pode retornar JSON de qualquer controlador::

    // src/Controller/DefaultController.php
    namespace App\Controller;

    use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
    use Symfony\Component\Routing\Annotation\Route;

    class DefaultController extends AbstractController
    {
        // ...

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
    }

Mas para uma API *verdadeiramente* rica, tente instalar a `API Platform`_:

.. code-block:: terminal

    $ composer require api

Esse é um alias para :ref:`o pack do Symfony <symfony-packs>` ``api-platform/api-pack``,
que depende de vários outros pacotes, como os componentes Symfony Security e
Symfony Validator, além do Doctrine ORM. De fato, o Flex instalou *5* receitas!

Mas, como de costume, podemos começar imediatamente a usar a nova biblioteca. Deseja criar uma
API rica para uma tabela ``product``? Crie uma entidade ``Product`` e adicione a
anotação ``@ApiResource()``::

    // src/Entity/Product.php
    namespace App\Entity;

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
         * @ORM\Column(type="int")
         */
        private $price;

        // ...
    }

Feito! Agora você tem endpoints para listar, adicionar, atualizar e excluir produtos! Não acredita
em mim? Liste suas rotas executando:

.. code-block:: terminal

    $ php bin/console debug:router

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

.. _ easily-remove-recipes:

Removendo Receitas
------------------

Ainda não está convencida? Não tem problema: remova a biblioteca:

.. code-block:: terminal

    $ composer remove api

O Flex irá *desinstalar* as receitas: removendo arquivos e desfazendo mudanças para retornar
a sua aplicação ao seu estado original. Experimente sem se preocupar.

Mais Recursos, Arquitetura e Velocidade
---------------------------------------

Espero que você esteja tão animada com o Flex quanto eu! Mas ainda temos *mais um* capítulo,
e é o mais importante até agora. Quero mostrar como o Symfony permite que você crie recursos
rapidamente *sem* sacrificar a qualidade do código ou a performance. Trata-se do
container de serviços, e ele é o superpoder do Symfony. Continue lendo sobre: :doc:`/quick_tour/the_architecture`.

.. _`https://flex.symfony.com`: https://flex.symfony.com
.. _`API Platform`: https://api-platform.com/
.. _`Twig`: https://twig.symfony.com/
