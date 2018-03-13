Organizando sua Lógica de Negócio
=================================

Em software de computador, **lógica de negócio** ou lógica de domínio é "a parte do
programa que codifica as regras de negócio do mundo real que determinam como os dados podem
ser criados, exibidos, armazenados e alterados" (leia a `definição completa`_).

Nas aplicações Symfony, a lógica de negócio é todo código personalizado que você escreve para
sua aplicação que não é específico do framework (por exemplo, roteamento e controllers).
Classes de domínio, entidades do Doctrine e classes PHP usuais que são usadas como
serviços são bons exemplos de lógica de negócio.

Para a maioria dos projetos, você deve manter todo o seu código dentro do diretório ``src/``.
Lá você pode criar quaisquer diretórios que você queira para organizar as coisas:

.. code-block:: text

    projeto-symfony/
    ├─ config/
    ├─ public/
    ├─ src/
    │  └─ Utils/
    │     └─ MinhaClasse.php
    ├─ tests/
    ├─ var/
    └─ vendor/

.. _services-naming-and-format:

Serviços: Nomenclatura e Configuração
-------------------------------------

.. best-practice::

    Use o autowiring para automatizar a configuração dos serviços da aplicação.

:doc:`O autowiring de serviço </service_container/autowiring>` é um recurso fornecido
pelo Container de Serviço do Symfony para gerenciar serviços com configuração mínima. Ele
lê as declarações de tipo no seu construtor (ou em outros métodos) e automaticamente
passa os serviços corretos para cada método. Ele também pode adicionar
:doc:`tags de serviço </service_container/tags>` aos serviços necessários, tais como
extensões Twig, subscribers de eventos, etc.

A aplicação do blog precisa de um utilitário que possa transformar um título de post (por exemplo,
"Olá, Mundo") em um slug (por exemplo, "ola-mundo") para incluí-lo como parte do
URL do post. Vamos criar uma nova classe ``Slugger`` em ``src/Utils/``::

    // src/Utils/Slugger.php
    namespace App\Utils;

    class Slugger
    {
        public function slugify(string $value): string
        {
            // ...
        }
    }

Se você estiver usando a :ref:`configuração padrão do services.yaml <service-container-services-load-example>`,
esta classe é auto-registrada como um serviço cujo id é ``App\Utils\Slugger`` (ou
simplesmente ``Slugger::class`` se a classe já estiver importada no seu código).

.. best-practice::

    O id dos serviços da sua aplicação deve ser igual ao nome da sua classe,
    exceto quando você possui vários serviços configurados para a mesma classe (nesse
    caso, use um id no formato snake case).

Agora você pode usar o slugger personalizado em qualquer outro serviço ou classe de controller,
como o ``AdminController``::

    use App\Utils\Slugger;

    public function create(Request $request, Slugger $slugger)
    {
        // ...

        if ($form->isSubmitted() && $form->isValid()) {
            $slug = $slugger->slugify($post->getTitle());
            $post->setSlug($slug);

            // ...
        }
    }

Os serviços também podem ser :ref:`públicos ou privados <container-public>`. Se você usar a
:ref:`configuração padrão do services.yaml <service-container-services-load-example>`,
todos os serviços são privados por padrão.

.. best-practice::

    Os serviços devem ser ``private`` sempre que possível. Isso impedirá que você
    acesse tais serviços por meio de ``$container->get()``. Em vez disso, você precisará usar
    injeção de dependência.

Formato de Serviço: YAML
------------------------

Na seção anterior, o YAML foi usado para definir o serviço.

.. best-practice::

    Use o formato YAML para definir seus próprios serviços.

Isso é controverso e, em nossa experiência, o uso de YAML e XML é
distribuído uniformemente entre os desenvolvedores, com uma pequena preferência pelo YAML.
Ambos os formatos têm o mesmo desempenho, então esta é, enfim, uma questão de
gosto pessoal.

Recomendamos o YAML porque é conciso e amigável aos novatos. Você pode,
naturalmente, usar qualquer formato que preferir.

Usando uma Camada de Persistência
---------------------------------

O Symfony é um framework HTTP que só se preocupa em gerar uma resposta HTTP
para cada requisição HTTP. É por isso que o Symfony não fornece uma forma de falar com
uma camada de persistência (por exemplo, banco de dados, API externa). Você pode escolher qualquer
biblioteca ou estratégia que desejar para isso.

Na prática, muitas aplicações Symfony contam com o `projeto independente Doctrine`_
para definir seu modelo usando entidades e repositórios.
Assim como na lógica de negócio, recomendamos armazenar as entidades do Doctrine no
diretório ``src/Entity/``.

As três entidades definidas pela nossa aplicação do blog são um bom exemplo:

.. code-block:: text

    projeto-symfony/
    ├─ ...
    └─ src/
       └─ Entity/
          ├─ Comment.php
          ├─ Post.php
          └─ User.php

Informações de Mapeamento do Doctrine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As Entidades do Doctrine são objetos PHP simples que você armazena em algum "banco de dados".
O Doctrine só conhece as suas entidades através dos metadados de mapeamento configurados
para suas classes de modelo. O Doctrine suporta quatro formatos de metadados: YAML, XML,
PHP e anotações.

.. best-practice::

    Use anotações para definir as informações de mapeamento das entidades do Doctrine.

As anotações são, de longe, a forma mais conveniente e ágil de configurar e
procurar informações de mapeamento::

    namespace App\Entity;

    use Doctrine\ORM\Mapping as ORM;
    use Doctrine\Common\Collections\ArrayCollection;

    /**
     * @ORM\Entity
     */
    class Post
    {
        const NUMBER_OF_ITEMS = 10;

        /**
         * @ORM\Id
         * @ORM\GeneratedValue
         * @ORM\Column(type="integer")
         */
        private $id;

        /**
         * @ORM\Column(type="string")
         */
        private $title;

        /**
         * @ORM\Column(type="string")
         */
        private $slug;

        /**
         * @ORM\Column(type="text")
         */
        private $content;

        /**
         * @ORM\Column(type="string")
         */
        private $authorEmail;

        /**
         * @ORM\Column(type="datetime")
         */
        private $publishedAt;

        /**
         * @ORM\OneToMany(
         *      targetEntity="Comment",
         *      mappedBy="post",
         *      orphanRemoval=true
         * )
         * @ORM\OrderBy({"publishedAt"="ASC"})
         */
        private $comments;

        public function __construct()
        {
            $this->publishedAt = new \DateTime();
            $this->comments = new ArrayCollection();
        }

        // getters e setters ...
    }

Todos os formatos têm o mesmo desempenho, por isso esta é, mais uma vez, uma
questão de gosto.

Fixtures de Dados
~~~~~~~~~~~~~~~~~

Como o suporte a fixtures não está habilitado por padrão no Symfony, você deve executar
o seguinte comando para instalar o bundle de fixtures do Doctrine:

.. code-block:: terminal

    $ composer require "doctrine/doctrine-fixtures-bundle"

Então, este bundle é habilitado automaticamente, mas apenas nos ambientes ``dev`` e
``test``::

    // config/bundles.php

    return [
        // ...
        Doctrine\Bundle\FixturesBundle\DoctrineFixturesBundle::class => ['dev' => true, 'test' => true],
    ];

Recomendamos criar apenas *uma* `classe fixture`_ por simplicidade, embora
você possa ter mais se essa classe ficar muito grande.

Supondo que você tenha pelo menos uma classe fixture e que o acesso ao banco de dados
esteja configurado corretamente, você pode carregar suas fixtures executando o seguinte
comando:

.. code-block:: terminal

    $ php bin/console doctrine:fixtures:load

    Careful, database will be purged. Do you want to continue Y/N ? Y
      > purging database
      > loading App\DataFixtures\ORM\LoadFixtures

Padrões de Codificação
----------------------

O código-fonte do Symfony segue os padrões de codificação `PSR-1`_ e `PSR-2`_ que
foram definidos pela comunidade PHP. Você pode aprender mais sobre
:doc:`os Padrões de Codificação do Symfony </contributing/code/standards>` e até mesmo
usar o `PHP-CS-Fixer`_, que é um utilitário de linha de comando que pode corrigir os
padrões de codificação de uma base de código inteira em questão de segundos.

----

Próxima: :doc:`/best_practices/controllers`

.. _`definição completa`: https://en.wikipedia.org/wiki/Business_logic
.. _`projeto independente Doctrine`: http://www.doctrine-project.org/
.. _`classe fixture`: https://symfony.com/doc/current/bundles/DoctrineFixturesBundle/index.html#writing-simple-fixtures
.. _`PSR-1`: https://www.php-fig.org/psr/psr-1/
.. _`PSR-2`: https://www.php-fig.org/psr/psr-2/
.. _`PHP-CS-Fixer`: https://github.com/FriendsOfPHP/PHP-CS-Fixer
