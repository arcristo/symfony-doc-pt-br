Formulários
===========

Forms são um dos componentes Symfony mais mal utilizados devido ao seu amplo escopo e
à interminável lista de recursos. Neste capítulo iremos mostrar algumas das melhores
práticas para que você possa aproveitar os formulários, mas também possa fazer o trabalho rapidamente.

Construindo Formulários
-----------------------

.. best-practice::

    Defina seus formulários como classes PHP.

O componente Form permite que você crie formulários diretamente no código do seu controller.
Isso é perfeito, se você não precisa reutilizar o formulário em algum outro lugar. Mas,
para organização e reuso, recomendamos que você defina cada formulário em sua própria
classe PHP::

    namespace App\Form;

    use App\Entity\Post;
    use Symfony\Component\Form\AbstractType;
    use Symfony\Component\Form\FormBuilderInterface;
    use Symfony\Component\OptionsResolver\OptionsResolver;
    use Symfony\Component\Form\Extension\Core\Type\TextareaType;
    use Symfony\Component\Form\Extension\Core\Type\EmailType;
    use Symfony\Component\Form\Extension\Core\Type\DateTimeType;

    class PostType extends AbstractType
    {
        public function buildForm(FormBuilderInterface $builder, array $options)
        {
            $builder
                ->add('title')
                ->add('summary', TextareaType::class)
                ->add('content', TextareaType::class)
                ->add('authorEmail', EmailType::class)
                ->add('publishedAt', DateTimeType::class)
            ;
        }

        public function configureOptions(OptionsResolver $resolver)
        {
            $resolver->setDefaults([
                'data_class' => Post::class,
            ]);
        }
    }

.. best-practice::

    Coloque as classes de tipo de formulário no namespace ``App\Form``, a menos que você
    use outras classes de formulário personalizadas como data transformers.

Para usar a classe, use ``createForm()`` e passe o nome da classe totalmente qualificado::

    // ...
    use App\Form\PostType;

    // ...
    public function new(Request $request)
    {
        $post = new Post();
        $form = $this->createForm(PostType::class, $post);

        // ...
    }

Configuração do Botão de Formulário
-----------------------------------

Classes de formulário devem tentar ser agnósticas a respeito de *onde* serão utilizadas. Isso
as torna mais fáceis de reutilizar mais tarde.

.. best-practice::

    Adicione botões nos templates, não nas classes de formulário ou nos controllers.

O componente Form do Symfony permite que você adicione botões como campos no seu formulário.
Esta é uma boa maneira de simplificar o template que renderiza o seu formulário. Mas se você
adicionar os botões diretamente na sua classe de formulário, isso efetivamente limitará o
escopo desse formulário::

    class PostType extends AbstractType
    {
        public function buildForm(FormBuilderInterface $builder, array $options)
        {
            $builder
                // ...
                ->add('save', SubmitType::class, ['label' => 'Criar Post'])
            ;
        }

        // ...
    }

Esse formulário *pode* ter sido projetado para criar posts, mas se você quisesse
reutilizá-lo para editar posts, a label do botão estaria errada. Em vez disso,
alguns desenvolvedores configuram botões de formulário no controller::

    namespace App\Controller\Admin;

    use App\Entity\Post;
    use App\Form\PostType;
    use Symfony\Component\HttpFoundation\Request;
    use Symfony\Bundle\FrameworkBundle\Controller\Controller;
    use Symfony\Component\Form\Extension\Core\Type\SubmitType;

    class PostController extends Controller
    {
        // ...

        public function new(Request $request)
        {
            $post = new Post();
            $form = $this->createForm(PostType::class, $post);
            $form->add('submit', SubmitType::class, [
                'label' => 'Criar',
                'attr' => ['class' => 'btn btn-default pull-right'],
            ]);

            // ...
        }
    }

Este também é um erro importante, porque você está misturando a marcação de apresentação
(labels, classes CSS, etc.) com código PHP puro. Separação de responsabilidades é
sempre uma boa prática a seguir, então coloque todas as coisas relacionadas à view na
camada da view:

.. code-block:: html+twig

    {{ form_start(form) }}
        {{ form_widget(form) }}

        <input type="submit" class="btn" value="Criar" />
    {{ form_end(form) }}

Renderizando o Formulário
-------------------------

Há muitas maneiras de renderizar o seu formulário, variando de renderizar a coisa
toda em uma linha até renderizar cada parte de cada campo de forma independente. A
melhor maneira depende da quantidade de personalização que você precisa.

Uma das maneiras mais simples - que é especialmente útil durante o desenvolvimento -
é renderizar as tags de formulário e usar a função ``form_widget()`` para renderizar
todos os campos:

.. code-block:: html+twig

    {{ form_start(form, {attr: {class: 'my-form-class'} }) }}
        {{ form_widget(form) }}
    {{ form_end(form) }}

Se você precisar de mais controle sobre como seus campos são renderizados, então você deve
remover a função ``form_widget(form)`` e renderizar seus campos individualmente.
Veja :doc:`/form/form_customization` para obter mais informações sobre isso e sobre como você
pode controlar *como* o formulário é renderizado a nível global, utilizando temas de formulário.

Tratando Submissões de Formulário
---------------------------------

Tratar a submissão de um formulário geralmente segue um modelo semelhante::

    public function new(Request $request)
    {
        // constrói o form ...

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $entityManager = $this->getDoctrine()->getManager();
            $entityManager->persist($post);
            $entityManager->flush();

            return $this->redirectToRoute('admin_post_show', [
                'id' => $post->getId()
            ]);
        }

        // renderiza o template
    }

Recomendamos que você use uma única action para renderizar o formulário e
tratar a submissão do formulário. Por exemplo, você *poderia* ter uma action ``new()`` que
*apenas* renderiza o formulário e uma action ``create()`` que *apenas* processa a submissão do
formulário. Estas duas actions serão quase idênticas. Portanto, é muito mais simples deixar
``new()`` lidar com tudo.

Próxima: :doc:`/best_practices/i18n`
