Configuração
============

Configuração geralmente envolve diferentes partes da aplicação (tais como infraestrutura
e credenciais de segurança) e diferentes ambientes (desenvolvimento, produção).
É por isso que o Symfony recomenda que você divida a configuração da aplicação em
três partes.

.. _config-parameters.yml:

Configuração Relacionada à Infraestrutura
-----------------------------------------

Estas são as opções que mudam de uma máquina para outra (por exemplo, da sua
máquina de desenvolvimento para o servidor de produção) mas que não alteram o
comportamento da aplicação.

.. best-practice::

    Defina as opções de configuração relacionadas à infraestrutura como variáveis de
    ambiente. Durante o desenvolvimento, use o arquivo ``.env`` na raiz do seu
    projeto para configurá-las.

Por padrão, o Symfony adiciona esses tipos de opções ao arquivo ``.env`` ao
instalar novas dependências na aplicação:

.. code-block:: bash

    # .env
    ###> doctrine/doctrine-bundle ###
    DATABASE_URL=sqlite:///%kernel.project_dir%/var/data/blog.sqlite
    ###< doctrine/doctrine-bundle ###

    ###> symfony/swiftmailer-bundle ###
    MAILER_URL=smtp://localhost?encryption=ssl&auth_mode=login&username=&password=
    ###< symfony/swiftmailer-bundle ###

    # ...

Essas opções não estão definidas no arquivo ``config/services.yaml`` porque
elas não têm nada a ver com o comportamento da aplicação. Em outras palavras, sua
aplicação não se importa com a localização do seu banco de dados ou as credenciais
para acessá-lo, desde que o banco de dados esteja configurado corretamente.

.. caution::

    Esteja ciente de que fazer o dumping do conteúdo das variáveis ``$_SERVER`` e ``$_ENV``
    ou imprimir o conteúdo de ``phpinfo()`` exibirá os valores das
    variáveis de ambiente, expondo informações sensíveis, como as credenciais do
    banco de dados.

.. _best-practices-canonical-parameters:

Parâmetros Canônicos
~~~~~~~~~~~~~~~~~~~~

.. best-practice::

    Defina todas as variáveis de ambiente da sua aplicação no arquivo ``.env.dist``.

O Symfony inclui um arquivo de configuração chamado ``.env.dist`` na raiz do projeto,
que armazena a lista canônica de variáveis de ambiente para a aplicação.

Sempre que uma nova variável de ambiente for definida para a aplicação, você também deve adicioná-la a
este arquivo e enviar as alterações ao seu sistema de controle de versão para que seus
colegas de trabalho possam atualizar seus arquivos ``.env``.

Configuração Relacionada à Aplicação
------------------------------------

.. best-practice::

    Defina as opções de configuração relacionadas ao comportamento da aplicação no
    arquivo ``config/services.yaml``.

O arquivo ``services.yaml`` contém as opções usadas pela aplicação para
modificar seu comportamento, como o remetente de notificações por e-mail, ou as `flags de recursos`_
habilitadas. Definir esses valores no arquivo ``.env`` adicionaria uma camada
extra de configuração que não é necessária porque você não precisa ou não deseja que esses
valores de configuração sejam alterados em cada servidor.

As opções de configuração definidas no arquivo ``services.yaml`` podem variar de um
:doc:`ambiente </configuration/environments>` para outro. É por isso que o Symfony
suporta a definição dos arquivos ``config/services_dev.yaml`` e ``config/services_prod.yaml``
para que você possa sobrescrever valores específicos para cada ambiente.

Constantes vs. Opções de Configuração
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Um dos erros mais comuns ao definir a configuração da aplicação é
criar novas opções para valores que nunca mudam, como o número de itens para
resultados paginados.

.. best-practice::

    Use constantes para definir opções de configuração que raramente mudam.

A abordagem tradicional para definir opções de configuração fez com que muitas
aplicações Symfony incluíssem uma opção como a seguinte, que seria usada
para controlar o número de posts a serem exibidos na página inicial do blog:

.. code-block:: yaml

    # config/services.yaml
    parameters:
        homepage.number_of_items: 10

Se você fez algo assim no passado, é provável que, na verdade, você
*nunca* precisou realmente alterar esse valor. Criar uma opção de
configuração para um valor que você nunca irá configurar simplesmente não é necessário.
Nossa recomendação é definir esses valores como constantes na sua aplicação.
Você poderia, por exemplo, definir uma constante ``NUMBER_OF_ITEMS`` na entidade ``Post``::

    // src/Entity/Post.php
    namespace App\Entity;

    class Post
    {
        const NUMBER_OF_ITEMS = 10;

        // ...
    }

A principal vantagem em definir constantes é que você pode usar seus valores
em qualquer lugar na sua aplicação. Ao usar parâmetros, eles só estão disponíveis
em locais com acesso ao container do Symfony.

Constantes podem ser usadas, por exemplo, em seus templates Twig graças à
`função constant()`_:

.. code-block:: html+twig

    <p>
        Exibindo os {{ constant('NUMBER_OF_ITEMS', post) }} resultados mais recentes.
    </p>

E as entidades e repositórios do Doctrine agora podem acessar facilmente esses valores,
ao passo que não podem acessar os parâmetros do container::

    namespace App\Repository;

    use App\Entity\Post;
    use Doctrine\ORM\EntityRepository;

    class PostRepository extends EntityRepository
    {
        public function findLatest($limit = Post::NUMBER_OF_ITEMS)
        {
            // ...
        }
    }

A única desvantagem notável no uso de constantes para este tipo de valores de
configuração é que você não pode redefini-los facilmente em seus testes.

Nomenclatura de Parâmetros
--------------------------

.. best-practice::

    O nome dos seus parâmetros de configuração deve ser o mais curto possível e
    deve incluir um prefixo comum para toda a aplicação.

Usar ``app.`` como o prefixo dos seus parâmetros é uma prática comum para evitar
colisões com parâmetros do Symfony e de bundles ou bibliotecas de terceiros. Em seguida, use
apenas uma ou duas palavras para descrever o propósito do parâmetro:

.. code-block:: yaml

    # config/services.yaml
    parameters:
        # não faça isso: 'dir' é muito genérico e não transmite nenhum significado
        app.dir: '...'
        # faça isso: nomes curtos mas fáceis de entender
        app.contents_dir: '...'
        # tudo bem usar pontos, underscores, traços ou nada, mas seja
        # sempre consistente e use o mesmo formato para todos os parâmetros
        app.dir.contents: '...'
        app.contents-dir: '...'

----

Próxima: :doc:`/best_practices/business-logic`

.. _`flags de recursos`: https://en.wikipedia.org/wiki/Feature_toggle
.. _`função constant()`: http://twig.sensiolabs.org/doc/functions/constant.html
