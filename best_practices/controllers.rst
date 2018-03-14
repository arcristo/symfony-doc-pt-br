Controllers
===========

O Symfony segue a filosofia de *"controllers magros e modelos gordos"*. Isso
significa que os controllers devem conter apenas a fina camada de *código de cola*
necessária para coordenar as diferentes partes da aplicação.

Os métodos do seu controller devem apenas chamar outros serviços, disparar algum evento,
se necessário, e então retornar uma resposta, mas eles não devem conter nenhuma
lógica de negócio de fato. Se eles contêm, refatore-as, retirando-as do controller e colocando-as em um serviço.

.. best-practice::

    Faça o seu controller estender o controller base ``AbstractController``
    fornecido pelo Symfony e use anotações para configurar o roteamento, cache e
    segurança sempre que possível.

O acoplamento dos controllers ao framework subjacente permite que você aproveite
todos os seus recursos e aumenta a sua produtividade.

E uma vez que seus controllers devem ser magros e conter nada mais que
algumas linhas de *código de cola*, gastar horas tentando desacoplá-los do seu
framework não te beneficiará a longo prazo. A quantidade de tempo *desperdiçado*
não vale o benefício.

Além disso, o uso de anotações para roteamento, cache e segurança simplifica
a configuração. Você não precisa navegar por dezenas de arquivos criados com diferentes
formatos (YAML, XML, PHP): toda a configuração está exatamente onde você precisa
e usa apenas um formato.

Em geral, isso significa que você deve desacoplar sua lógica de negócio
do framework e, ao mesmo tempo, acoplar os seus controllers
e roteamento *ao* framework de forma agressiva, para tirar o máximo proveito dele.

Nomenclatura da Action do Controller
------------------------------------

.. best-practice::

    Não adicione o sufixo ``Action`` aos métodos das actions do controller.

As primeiras versões do Symfony exigiam que os nomes dos métodos do controller terminassem em
``Action`` (por exemplo, ``newAction()``, ``showAction()``). Este sufixo tornou-se opcional
quando as anotações foram introduzidas para controllers. Nas aplicações Symfony modernas
este sufixo não é necessário nem recomendado, então você pode removê-lo com segurança.

Configuração de Roteamento
--------------------------

Para carregar rotas definidas com anotações em seus controllers, adicione a seguinte
configuração no arquivo de configuração de roteamento principal:

.. code-block:: yaml

    # config/routes.yaml
    controllers:
        resource: '../src/Controller/'
        type:     annotation

Esta configuração irá carregar as anotações de qualquer controller armazenado no
diretório ``src/Controller/`` e até mesmo em seus subdiretórios. Portanto, se a sua aplicação
define muitos controllers, é perfeitamente adequado reorganizá-los em subdiretórios:

.. code-block:: text

    <seu-projeto>/
    ├─ ...
    └─ src/
       ├─ ...
       └─ Controller/
          ├─ DefaultController.php
          ├─ ...
          ├─ Api/
          │  ├─ ...
          │  └─ ...
          └─ Backend/
             ├─ ...
             └─ ...

Configuração de Template
------------------------

.. best-practice::

    Não use a anotação ``@Template`` para configurar o template usado pelo
    controller.

A anotação ``@Template`` é útil, mas também envolve um pouco de magia. Nós
não achamos que seu benefício vale a magia e, portanto, não recomendamos o seu
uso.

Na maioria das vezes, ``@Template`` é usado sem parâmetros, o que torna
mais difícil saber qual template está sendo renderizado. Isso também torna
menos óbvio para iniciantes que um controller deve sempre retornar um objeto
Response (a menos que você esteja usando uma camada de view).

Como é a Aparência do Controller
--------------------------------

Considerando tudo isso, aqui está um exemplo de como deve ser a aparência do controller
para a página inicial da nossa aplicação:

.. code-block:: php

    namespace App\Controller;

    use App\Entity\Post;
    use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
    use Symfony\Component\Routing\Annotation\Route;

    class DefaultController extends AbstractController
    {
        /**
         * @Route("/", name="homepage")
         */
        public function index()
        {
            $posts = $this->getDoctrine()
                ->getRepository(Post::class)
                ->findLatest();

            return $this->render('default/index.html.twig', [
                'posts' => $posts,
            ]);
        }
    }

Obtendo Serviços
----------------

Se você estender a classe base ``AbstractController``, você não pode acessar serviços
diretamente do container via ``$this->container->get()`` ou ``$this->get()``.
Em vez disso, você deve usar injeção de dependência para obter serviços: mais facilmente feito ao
:ref:`declarar os tipos dos argumentos dos métodos de action <controller-accessing-services>`:

.. best-practice::

    Não use ``$this->get()`` ou ``$this->container->get()`` para obter serviços
    do container. Em vez disso, use injeção de dependência.

Ao não obter serviços diretamente do container, você pode tornar os seus serviços
*privados*, o que tem :ref:`várias vantagens <services-why-private>`.

.. _best-practices-paramconverter:

Usando o ParamConverter
-----------------------

Se você estiver usando o Doctrine, então você pode, *opcionalmente*, usar o `ParamConverter`_
para consultar automaticamente uma entidade e passá-la como um argumento para o seu controller.

.. best-practice::

    Use o truque do ParamConverter para consultar automaticamente as entidades do Doctrine
    quando for simples e conveniente.

Por exemplo:

.. code-block:: php

    use App\Entity\Post;
    use Symfony\Component\Routing\Annotation\Route;

    /**
     * @Route("/{id}", name="admin_post_show")
     */
    public function show(Post $post)
    {
        $deleteForm = $this->createDeleteForm($post);

        return $this->render('admin/post/show.html.twig', [
            'post' => $post,
            'delete_form' => $deleteForm->createView(),
        ]);
    }

Normalmente, você esperaria um argumento ``$id`` para ``show()``. Em vez disso, ao criar um
novo argumento (``$post``) e declará-lo com o tipo de classe ``Post`` (que é uma
entidade do Doctrine), o ParamConverter consulta automaticamente um objeto cuja
propriedade ``$id`` corresponde ao valor ``{id}``. Também mostrará uma página 404 se não
for possível encontrar nenhum ``Post``.

Quando as Coisas Ficam Mais Avançadas
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

O exemplo acima funciona sem qualquer configuração porque o nome do curinga
``{id}`` corresponde ao nome da propriedade na entidade. Se isso não for verdade, ou
se você tiver uma lógica ainda mais complexa, a coisa mais fácil a fazer é apenas consultar a
entidade manualmente. Em nossa aplicação, temos essa situação no
``CommentController``:

.. code-block:: php

    /**
     * @Route("/comment/{postSlug}/new", name="comment_new")
     */
    public function new(Request $request, $postSlug)
    {
        $post = $this->getDoctrine()
            ->getRepository(Post::class)
            ->findOneBy(['slug' => $postSlug]);

        if (!$post) {
            throw $this->createNotFoundException();
        }

        // ...
    }

Você também pode usar a configuração ``@ParamConverter``, que é infinitamente
flexível:

.. code-block:: php

    use App\Entity\Post;
    use Sensio\Bundle\FrameworkExtraBundle\Configuration\ParamConverter;
    use Symfony\Component\HttpFoundation\Request;
    use Symfony\Component\Routing\Annotation\Route;

    /**
     * @Route("/comment/{postSlug}/new", name="comment_new")
     * @ParamConverter("post", options={"mapping"={"postSlug"="slug"}})
     */
    public function new(Request $request, Post $post)
    {
        // ...
    }

O ponto é este: o atalho do ParamConverter é ótimo para situações simples.
Mas você não deve esquecer que consultar entidades diretamente ainda é muito
fácil.

Pré e Pós Hooks
---------------

Se você precisar executar algum código antes ou depois da execução de seus controllers,
você pode usar o componente EventDispatcher para
:doc:`configurar filtros antes e depois </event_dispatcher/before_after_filters>`.

----

Próxima: :doc:`/best_practices/templates`

.. _`ParamConverter`: https://symfony.com/doc/current/bundles/SensioFrameworkExtraBundle/annotations/converters.html
