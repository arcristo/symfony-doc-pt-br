Segurança
=========

Autenticação e Firewalls (ou seja, Obtendo as Credenciais do Usuário)
---------------------------------------------------------------------

Você pode configurar o Symfony para autenticar seus usuários usando qualquer método que
desejar e carregar as informações do usuário a partir de qualquer fonte. Esse é um tema complexo, mas
o :doc:`guia de Segurança </security>` possui muitas informações sobre isso.

Independentemente das suas necessidades, a autenticação é configurada no ``security.yml``,
principalmente sob a chave ``firewalls``.

.. best-practice::

    A menos que você tenha dois sistemas de autenticação e usuários legitimamente
    diferentes (por exemplo, formulário de login para o site principal e um sistema de token somente para sua
    API), recomendamos ter apenas *uma* entrada de firewall com a chave ``anonymous``
    habilitada.

A maioria das aplicações possui apenas um sistema de autenticação e um conjunto de usuários.
Por esse motivo, você só precisa de *uma* entrada de firewall. Há exceções,
é claro, especialmente se você tiver seções web e API separadas no seu
site. Mas o ponto é manter as coisas simples.

Além disso, você deve usar a chave ``anonymous`` no seu firewall. Se
você precisa exigir que os usuários estejam logados em diferentes seções do seu
site (ou talvez quase *todas* as seções), use a área ``access_control``.

.. best-practice::

    Use o encoder ``bcrypt`` para codificar as senhas de seus usuários.

Se os seus usuários tiverem uma senha, recomendamos codificá-la usando o encoder ``bcrypt``,
em vez do encoder de hashing SHA-512 tradicional. As principais vantagens
do ``bcrypt`` são a inclusão de um valor de *salt* para proteger contra ataques
de rainbow table, e a sua natureza adaptativa, que permite torná-lo mais lento para
permanecer resistente a ataques de busca de força bruta.

Com isso em mente, aqui está a configuração de autenticação da nossa aplicação,
que utiliza um formulário de login para carregar usuários do banco de dados:

.. code-block:: yaml

    # config/packages/security.yaml
    security:
        encoders:
            App\Entity\User: bcrypt

        providers:
            database_users:
                entity: { class: App\Entity\User, property: username }

        firewalls:
            secured_area:
                pattern: ^/
                anonymous: true
                form_login:
                    check_path: login
                    login_path: login

                logout:
                    path: security_logout
                    target: homepage

    # ... access_control existe, mas não é mostrado aqui

.. tip::

    O código-fonte do nosso projeto contém comentários que explicam cada parte.

Autorização (ou seja, Negando o Acesso)
---------------------------------------

O Symfony oferece várias maneiras de impor a autorização, incluindo a configuração
``access_control`` no :doc:`security.yaml </reference/configuration/security>`, a
:ref:`anotação @Security <best-practices-security-annotation>` e o uso de
:ref:`isGranted <best-practices-directly-isGranted>` no serviço ``security.authorization_checker``
diretamente.

.. best-practice::

    * Para proteger padrões gerais de URL, use ``access_control``;
    * Sempre que possível, use a anotação ``@Security``;
    * Verifique a segurança diretamente no serviço ``security.authorization_checker`` sempre
      que você tiver uma situação mais complexa.

Há também diferentes formas de centralizar a sua lógica de autorização, como
com um voter de segurança personalizado.

.. best-practice::

    Defina um voter de segurança personalizado para implementar restrições mais finas.

.. _best-practices-security-annotation:

A Anotação @Security
--------------------

Para controlar o acesso num nível de controller a controller, use a anotação
``@Security`` sempre que possível. Elá é fácil de ler e é colocada de forma consistente
acima de cada action.

Na nossa aplicação, você precisa do ``ROLE_ADMIN`` para criar um novo post.
Usando ``@Security``, ficará parecido com:

.. code-block:: php

    use Sensio\Bundle\FrameworkExtraBundle\Configuration\Security;
    use Symfony\Component\Routing\Annotation\Route;
    // ...

    /**
     * Exibe um formulário para criar uma nova entidade Post.
     *
     * @Route("/new", name="admin_post_new")
     * @Security("has_role('ROLE_ADMIN')")
     */
    public function new()
    {
        // ...
    }

Usando Expressões para Restrições de Segurança Complexas
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Se a sua lógica de segurança for um pouco mais complexa, você pode usar uma :doc:`expressão </components/expression_language>`
dentro de ``@Security``. No exemplo a seguir, um usuário só pode acessar o
controller se o seu e-mail corresponder ao valor retornado pelo método
``getAuthorEmail()`` do objeto ``Post``:

.. code-block:: php

    use App\Entity\Post;
    use Sensio\Bundle\FrameworkExtraBundle\Configuration\Security;
    use Symfony\Component\Routing\Annotation\Route;

    /**
     * @Route("/{id}/edit", name="admin_post_edit")
     * @Security("user.getEmail() == post.getAuthorEmail()")
     */
    public function edit(Post $post)
    {
        // ...
    }

Note que isso requer o uso do `ParamConverter`_, que automaticamente
consulta o objeto ``Post`` e o coloca no argumento ``$post``. Isso
é o que torna possível usar a variável ``post`` na expressão.

Isso tem uma grande desvantagem: uma expressão em uma anotação não pode facilmente
ser reutilizada em outras partes da aplicação. Imagine que você deseja adicionar
um link em um template que só será visto pelos autores. Agora você
precisará repetir o código da expressão usando a sintaxe do Twig:

.. code-block:: html+jinja

    {% if app.user and app.user.email == post.authorEmail %}
        <a href=""> ... </a>
    {% endif %}

A solução mais fácil - se a sua lógica for suficientemente simples - é adicionar um novo método
à entidade ``Post`` que verifica se um determinado usuário é o seu autor:

.. code-block:: php

    // src/Entity/Post.php
    // ...

    class Post
    {
        // ...

        /**
         * O usuário fornecido é o autor deste post?
         *
         * @return bool
         */
        public function isAuthor(User $user = null)
        {
            return $user && $user->getEmail() == $this->getAuthorEmail();
        }
    }

Agora você pode reutilizar esse método tanto no template quanto na expressão de segurança:

.. code-block:: php

    use App\Entity\Post;
    use Sensio\Bundle\FrameworkExtraBundle\Configuration\Security;
    use Symfony\Component\Routing\Annotation\Route;

    /**
     * @Route("/{id}/edit", name="admin_post_edit")
     * @Security("post.isAuthor(user)")
     */
    public function edit(Post $post)
    {
        // ...
    }

.. code-block:: html+jinja

    {% if post.isAuthor(app.user) %}
        <a href=""> ... </a>
    {% endif %}

.. _best-practices-directly-isGranted:
.. _checking-permissions-without-security:
.. _manually-checking-permissions:

Verificando as Permissões sem @Security
---------------------------------------

O exemplo acima com ``@Security`` só funciona porque estamos usando o
:ref:`ParamConverter <best-practices-paramconverter>`, que dá à expressão
acesso à variável ``post``. Se você não usá-lo, ou tiver algum outro
caso de uso mais avançado, você sempre pode fazer a mesma verificação de segurança no PHP:

.. code-block:: php

    /**
     * @Route("/{id}/edit", name="admin_post_edit")
     */
    public function edit($id)
    {
        $post = $this->getDoctrine()
            ->getRepository(Post::class)
            ->find($id);

        if (!$post) {
            throw $this->createNotFoundException();
        }

        if (!$post->isAuthor($this->getUser())) {
            $this->denyAccessUnlessGranted('edit', $post);
        }
        // código equivalente sem usar o atalho "denyAccessUnlessGranted()":
        //
        // use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        // ...
        //
        // if (!$this->get('security.authorization_checker')->isGranted('edit', $post)) {
        //    throw $this->createAccessDeniedException();
        // }

        // ...
    }

Voters de Segurança
-------------------

Se a sua lógica de segurança é complexa e não pode ser centralizada em um método como
``isAuthor()``, você deve aproveitar os voters personalizados. Esses são muito mais fáceis que
:doc:`ACLs </security/acl>` e lhe darão a flexibilidade que você precisa em quase
todos os casos.

Primeiro, crie uma classe voter. O exemplo a seguir mostra um voter que implementa
a mesma lógica de ``getAuthorEmail()`` que você usou acima:

.. code-block:: php

    namespace App\Security;

    use App\Entity\Post;
    use Symfony\Component\Security\Core\Authentication\Token\TokenInterface;
    use Symfony\Component\Security\Core\Authorization\AccessDecisionManagerInterface;
    use Symfony\Component\Security\Core\Authorization\Voter\Voter;
    use Symfony\Component\Security\Core\User\UserInterface;

    class PostVoter extends Voter
    {
        const CREATE = 'create';
        const EDIT   = 'edit';

        private $decisionManager;

        public function __construct(AccessDecisionManagerInterface $decisionManager)
        {
            $this->decisionManager = $decisionManager;
        }

        protected function supports($attribute, $subject)
        {
            if (!in_array($attribute, [self::CREATE, self::EDIT])) {
                return false;
            }

            if (!$subject instanceof Post) {
                return false;
            }

            return true;
        }

        protected function voteOnAttribute($attribute, $subject, TokenInterface $token)
        {
            $user = $token->getUser();
            /** @var Post */
            $post = $subject; // $subject deve ser uma instância de Post, graças ao método supports

            if (!$user instanceof UserInterface) {
                return false;
            }

            switch ($attribute) {
                // se o usuário for um administrador, permita que crie novos posts
                case self::CREATE:
                    if ($this->decisionManager->decide($token, ['ROLE_ADMIN'])) {
                        return true;
                    }

                    break;

                // se o usuário for o autor da postagem, permita que edite os posts
                case self::EDIT:
                    if ($user->getEmail() === $post->getAuthorEmail()) {
                        return true;
                    }

                    break;
            }

            return false;
        }
    }

Se você estiver usando a :ref:`configuração padrão do services.yaml <service-container-services-load-example>`,
sua aplicação irá :ref:`configurar automaticamente <services-autoconfigure>` seu voter de
segurança e injetar uma instância de ``AccessDecisionManagerInterface`` nele graças ao
:doc:`autowiring </service_container/autowiring>`.

Agora, você pode usar o voter com a anotação ``@Security``:

.. code-block:: php

    /**
     * @Route("/{id}/edit", name="admin_post_edit")
     * @Security("is_granted('edit', post)")
     */
    public function edit(Post $post)
    {
        // ...
    }

Você também pode usá-lo diretamente com o serviço ``security.authorization_checker`` ou
através do atalho ainda mais fácil em um controller:

.. code-block:: php

    /**
     * @Route("/{id}/edit", name="admin_post_edit")
     */
    public function edit($id)
    {
        $post = ...; // consulta o post

        $this->denyAccessUnlessGranted('edit', $post);

        // ou sem o atalho:
        //
        // use Symfony\Component\Security\Core\Exception\AccessDeniedException;
        // ...
        //
        // if (!$this->get('security.authorization_checker')->isGranted('edit', $post)) {
        //    throw $this->createAccessDeniedException();
        // }
    }

Saiba Mais
----------

O `FOSUserBundle`_, desenvolvido pela comunidade Symfony, adiciona suporte para um
sistema de usuário baseado em banco de dados no Symfony. Ele também lida com tarefas comuns como
o registro de usuários e a funcionalidade de senha esquecida.

Ative o :doc:`recurso Lembrar-me </security/remember_me>` para
permitir que seus usuários permaneçam logados por um longo período de tempo.

Ao fornecer suporte ao cliente, às vezes é necessário acessar a aplicação
como algum *outro* usuário para que você possa reproduzir o problema. O Symfony fornece
a capacidade de :doc:`personificar usuários </security/impersonating_user>`.

Se a sua empresa usa um método de login de usuário que não é suportado pelo Symfony, você pode
desenvolver :doc:`seu próprio provider de usuário </security/custom_provider>` e
:doc:`seu próprio provider de autenticação </security/custom_authentication_provider>`.

----

Próxima: :doc:`/best_practices/web-assets`

.. _`ParamConverter`: https://symfony.com/doc/current/bundles/SensioFrameworkExtraBundle/annotations/converters.html
.. _`anotação @Security`: https://symfony.com/doc/current/bundles/SensioFrameworkExtraBundle/annotations/security.html
.. _`FOSUserBundle`: https://github.com/FriendsOfSymfony/FOSUserBundle
