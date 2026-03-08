import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EnfantQuizPage extends StatefulWidget {
  const EnfantQuizPage({super.key});

  @override
  State<EnfantQuizPage> createState() => _EnfantQuizPageState();
}

class _EnfantQuizPageState extends State<EnfantQuizPage>
    with SingleTickerProviderStateMixin {

  int questionIndex = 0;
  int score = 0;
  bool answered = false;
  String selectedAnswer = "";

  // Animation pour agrandir une bonne réponse
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.2,
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  final List<Map<String, dynamic>> questions = [
    // THÈME: ARBRES ET FORÊTS (10 questions)
    {
      "question": "🌳 Quel geste protège la nature ?",
      "options": [
        "Jeter des papiers par terre",
        "Planter un arbre",
        "Laisser couler l'eau"
      ],
      "answer": "Planter un arbre",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌲 Pourquoi les arbres sont-ils importants ?",
      "options": [
        "Ils produisent de l'oxygène",
        "Ils font du bruit",
        "Ils mangent des fruits"
      ],
      "answer": "Ils produisent de l'oxygène",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🍃 Que peut-on faire avec les feuilles mortes ?",
      "options": [
        "Les brûler toutes",
        "Faire du compost",
        "Les jeter à la poubelle"
      ],
      "answer": "Faire du compost",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌴 Combien de temps vit un arbre ?",
      "options": [
        "Quelques mois",
        "Plusieurs années, parfois des siècles",
        "Une semaine"
      ],
      "answer": "Plusieurs années, parfois des siècles",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🪵 Que faire avec du bois mort ?",
      "options": [
        "Le laisser pour les insectes",
        "Le jeter dans la rivière",
        "L'enterrer profondément"
      ],
      "answer": "Le laisser pour les insectes",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌱 Comment pousse un arbre ?",
      "options": [
        "À partir d'une graine",
        "À partir d'un caillou",
        "À partir de l'air"
      ],
      "answer": "À partir d'une graine",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🍂 Pourquoi les feuilles tombent en automne ?",
      "options": [
        "L'arbre se prépare pour l'hiver",
        "Les feuilles sont fatiguées",
        "C'est pour faire joli"
      ],
      "answer": "L'arbre se prépare pour l'hiver",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌳 Quel arbre perd ses feuilles en hiver ?",
      "options": [
        "Le sapin",
        "Le chêne",
        "Le pin"
      ],
      "answer": "Le chêne",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌲 Que peut-on faire pour sauver les forêts ?",
      "options": [
        "Utiliser moins de papier",
        "Couper tous les arbres",
        "Allumer des feux partout"
      ],
      "answer": "Utiliser moins de papier",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🪴 Combien faut-il d'arbres pour faire un livre ?",
      "options": [
        "Aucun",
        "Une partie d'un arbre",
        "100 arbres"
      ],
      "answer": "Une partie d'un arbre",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: RECYCLAGE (15 questions)
    {
      "question": "♻️ Que signifie le symbole avec 3 flèches ?",
      "options": ["Recycler", "Manger", "Dormir"],
      "answer": "Recycler",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🗑️ Dans quelle poubelle met-on le plastique ?",
      "options": [
        "La poubelle jaune",
        "La poubelle verte",
        "La poubelle rouge"
      ],
      "answer": "La poubelle jaune",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🍾 Combien de fois peut-on recycler une bouteille en verre ?",
      "options": [
        "Une seule fois",
        "À l'infini",
        "Jamais"
      ],
      "answer": "À l'infini",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "📰 Où jeter un vieux journal ?",
      "options": [
        "Poubelle recyclable",
        "Par terre",
        "Dans la rivière"
      ],
      "answer": "Poubelle recyclable",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🥫 Que devient une canette recyclée ?",
      "options": [
        "Une nouvelle canette",
        "Du jus de fruit",
        "De l'eau"
      ],
      "answer": "Une nouvelle canette",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "📦 Que faire d'un carton vide ?",
      "options": [
        "Le recycler",
        "Le brûler",
        "Le cacher sous le lit"
      ],
      "answer": "Le recycler",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🧃 Où jeter une brique de jus vide ?",
      "options": [
        "Poubelle jaune",
        "Dans l'évier",
        "Dans le jardin"
      ],
      "answer": "Poubelle jaune",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🎨 Peut-on recycler du papier sale ?",
      "options": [
        "Non, il va à la poubelle normale",
        "Oui, toujours",
        "Oui, dans le compost"
      ],
      "answer": "Non, il va à la poubelle normale",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🍶 Combien de temps met le verre à disparaître dans la nature ?",
      "options": [
        "4000 ans",
        "1 mois",
        "1 an"
      ],
      "answer": "4000 ans",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🔋 Où jeter des piles usagées ?",
      "options": [
        "Point de collecte spécial",
        "Poubelle normale",
        "Dans la terre"
      ],
      "answer": "Point de collecte spécial",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "👕 Que faire de vieux vêtements ?",
      "options": [
        "Les donner ou recycler",
        "Les jeter par terre",
        "Les brûler"
      ],
      "answer": "Les donner ou recycler",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "💡 Où recycler une ampoule ?",
      "options": [
        "Magasin ou déchetterie",
        "Poubelle normale",
        "Dans le jardin"
      ],
      "answer": "Magasin ou déchetterie",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "📱 Que faire d'un vieux téléphone ?",
      "options": [
        "Le recycler dans un point de collecte",
        "Le jeter à la poubelle",
        "L'enterrer"
      ],
      "answer": "Le recycler dans un point de collecte",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🧻 Le papier toilette se recycle-t-il ?",
      "options": [
        "Non, il va à la poubelle normale",
        "Oui, dans le recyclage",
        "Oui, au compost"
      ],
      "answer": "Non, il va à la poubelle normale",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🎁 Que faire avec du papier cadeau usagé ?",
      "options": [
        "Le réutiliser ou le recycler",
        "Le jeter immédiatement",
        "Le brûler"
      ],
      "answer": "Le réutiliser ou le recycler",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: OCÉANS ET ANIMAUX MARINS (12 questions)
    {
      "question": "🐢 Que faut-il éviter pour protéger les animaux ?",
      "options": [
        "Jeter du plastique dans l'eau",
        "Éteindre la lumière",
        "Donner de l'eau aux plantes"
      ],
      "answer": "Jeter du plastique dans l'eau",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌊 Combien de plastique finit dans l'océan chaque année ?",
      "options": [
        "8 millions de tonnes",
        "10 kilos",
        "Rien du tout"
      ],
      "answer": "8 millions de tonnes",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐟 Pourquoi les poissons mangent-ils du plastique ?",
      "options": [
        "Ils le confondent avec de la nourriture",
        "Ils aiment ça",
        "C'est bon pour eux"
      ],
      "answer": "Ils le confondent avec de la nourriture",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐋 Quel animal marin est menacé par la pollution ?",
      "options": [
        "Tous les animaux marins",
        "Aucun",
        "Seulement les requins"
      ],
      "answer": "Tous les animaux marins",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🦈 Comment protéger les océans ?",
      "options": [
        "Ne pas jeter de déchets",
        "Verser de l'huile",
        "Pêcher tous les poissons"
      ],
      "answer": "Ne pas jeter de déchets",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐙 Que mange une tortue de mer ?",
      "options": [
        "Méduses et algues",
        "Plastique uniquement",
        "Du pain"
      ],
      "answer": "Méduses et algues",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌊 Pourquoi l'océan est-il important ?",
      "options": [
        "Il produit de l'oxygène et régule le climat",
        "Pour faire des vagues",
        "Pour faire du sel"
      ],
      "answer": "Il produit de l'oxygène et régule le climat",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🦀 Que trouve-t-on dans l'estomac des animaux marins ?",
      "options": [
        "Souvent du plastique",
        "Des bonbons",
        "Des jouets"
      ],
      "answer": "Souvent du plastique",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐚 Pourquoi ramasser les déchets à la plage ?",
      "options": [
        "Pour que les animaux ne les mangent pas",
        "Pour décorer",
        "Ce n'est pas nécessaire"
      ],
      "answer": "Pour que les animaux ne les mangent pas",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🦭 Combien de temps met un sac plastique à se décomposer dans l'océan ?",
      "options": [
        "450 ans",
        "1 semaine",
        "1 an"
      ],
      "answer": "450 ans",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐠 Que signifie 'surpêche' ?",
      "options": [
        "Pêcher trop de poissons",
        "Pêcher avec des filets",
        "Pêcher en bateau"
      ],
      "answer": "Pêcher trop de poissons",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌊 Quel pourcentage de la Terre est couvert d'océans ?",
      "options": [
        "70%",
        "20%",
        "50%"
      ],
      "answer": "70%",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: ÉNERGIE ET ÉLECTRICITÉ (10 questions)
    {
      "question": "💡 Que faut-il faire quand on sort d'une pièce ?",
      "options": [
        "Éteindre la lumière",
        "Laisser allumé",
        "Casser l'ampoule"
      ],
      "answer": "Éteindre la lumière",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🔌 Pourquoi débrancher les appareils ?",
      "options": [
        "Ils consomment même éteints",
        "Pour faire de la place",
        "Ce n'est pas utile"
      ],
      "answer": "Ils consomment même éteints",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "☀️ Quelle énergie vient du soleil ?",
      "options": [
        "Énergie solaire",
        "Énergie nucléaire",
        "Énergie du pétrole"
      ],
      "answer": "Énergie solaire",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "💨 Qu'est-ce que l'énergie éolienne ?",
      "options": [
        "Énergie du vent",
        "Énergie du feu",
        "Énergie de l'eau"
      ],
      "answer": "Énergie du vent",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌞 Les panneaux solaires produisent de l'électricité avec quoi ?",
      "options": [
        "La lumière du soleil",
        "La pluie",
        "Le vent"
      ],
      "answer": "La lumière du soleil",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "📺 Que faire de la télé quand personne ne la regarde ?",
      "options": [
        "L'éteindre",
        "La laisser allumée",
        "Monter le son"
      ],
      "answer": "L'éteindre",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🔋 Quelle énergie ne pollue pas ?",
      "options": [
        "Énergie renouvelable",
        "Charbon",
        "Pétrole"
      ],
      "answer": "Énergie renouvelable",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "💡 Quelle ampoule consomme le moins ?",
      "options": [
        "Ampoule LED",
        "Ampoule classique",
        "Ampoule halogène"
      ],
      "answer": "Ampoule LED",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🏠 Comment économiser l'énergie à la maison ?",
      "options": [
        "Bien isoler les fenêtres",
        "Ouvrir toutes les fenêtres en hiver",
        "Laisser tout allumé"
      ],
      "answer": "Bien isoler les fenêtres",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌡️ Quelle température pour le chauffage en hiver ?",
      "options": [
        "19°C",
        "25°C",
        "30°C"
      ],
      "answer": "19°C",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: EAU (10 questions)
    {
      "question": "💧 Combien de temps faut-il pour se laver les dents ?",
      "options": [
        "2-3 minutes en fermant le robinet",
        "10 minutes avec l'eau qui coule",
        "30 secondes"
      ],
      "answer": "2-3 minutes en fermant le robinet",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚿 Qu'est-ce qui économise le plus d'eau ?",
      "options": [
        "Une douche rapide",
        "Un bain",
        "Laisser couler l'eau"
      ],
      "answer": "Une douche rapide",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚰 Pourquoi fermer le robinet ?",
      "options": [
        "Pour économiser l'eau",
        "Pour embêter les parents",
        "Ce n'est pas important"
      ],
      "answer": "Pour économiser l'eau",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "💦 Combien de litres d'eau utilise-t-on pour un bain ?",
      "options": [
        "150 litres",
        "10 litres",
        "50 litres"
      ],
      "answer": "150 litres",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌊 Quel pourcentage d'eau sur Terre est potable ?",
      "options": [
        "3%",
        "50%",
        "90%"
      ],
      "answer": "3%",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚱 Que faire si le robinet fuit ?",
      "options": [
        "Le réparer vite",
        "Le laisser fuir",
        "L'ignorer"
      ],
      "answer": "Le réparer vite",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌧️ Comment récupérer l'eau de pluie ?",
      "options": [
        "Avec un récupérateur",
        "Dans la rue",
        "On ne peut pas"
      ],
      "answer": "Avec un récupérateur",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🪴 Quand arroser les plantes ?",
      "options": [
        "Le soir ou le matin",
        "En plein soleil à midi",
        "Jamais"
      ],
      "answer": "Le soir ou le matin",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚿 Combien de litres économise-t-on avec une douche au lieu d'un bain ?",
      "options": [
        "100 litres",
        "10 litres",
        "5 litres"
      ],
      "answer": "100 litres",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "💧 Que faire de l'eau de cuisson des légumes ?",
      "options": [
        "Arroser les plantes quand elle est froide",
        "La jeter",
        "La boire"
      ],
      "answer": "Arroser les plantes quand elle est froide",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: ALIMENTATION ET COMPOST (10 questions)
    {
      "question": "🍎 Que faire des épluchures de fruits ?",
      "options": [
        "Les composter",
        "Les jeter par terre",
        "Les brûler"
      ],
      "answer": "Les composter",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🥕 Qu'est-ce que le compost ?",
      "options": [
        "Un engrais naturel fait avec des déchets organiques",
        "Un type de poubelle",
        "Un légume"
      ],
      "answer": "Un engrais naturel fait avec des déchets organiques",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🍌 Que peut-on mettre au compost ?",
      "options": [
        "Épluchures et restes de fruits/légumes",
        "Plastique et verre",
        "Piles et batteries"
      ],
      "answer": "Épluchures et restes de fruits/légumes",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🍞 Que faire du pain rassis ?",
      "options": [
        "Faire du pain perdu ou le composter",
        "Le jeter immédiatement",
        "Le cacher"
      ],
      "answer": "Faire du pain perdu ou le composter",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🥗 Pourquoi manger des fruits et légumes de saison ?",
      "options": [
        "Ils polluent moins au transport",
        "Ils sont plus chers",
        "Ce n'est pas important"
      ],
      "answer": "Ils polluent moins au transport",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🥦 Où poussent les légumes ?",
      "options": [
        "Dans la terre",
        "Dans les supermarchés",
        "Dans l'eau"
      ],
      "answer": "Dans la terre",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🍓 Pourquoi choisir des fruits locaux ?",
      "options": [
        "Moins de transport, moins de pollution",
        "Ils sont plus beaux",
        "Ils coûtent plus cher"
      ],
      "answer": "Moins de transport, moins de pollution",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🧈 Combien de temps met une peau de banane à se décomposer ?",
      "options": [
        "2 ans",
        "2 jours",
        "10 ans"
      ],
      "answer": "2 ans",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🥚 Que faire des coquilles d'œuf ?",
      "options": [
        "Les mettre au compost",
        "Les jeter à la poubelle",
        "Les manger"
      ],
      "answer": "Les mettre au compost",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌽 Que signifie 'bio' ?",
      "options": [
        "Cultivé sans pesticides chimiques",
        "Plus cher",
        "De couleur verte"
      ],
      "answer": "Cultivé sans pesticides chimiques",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: TRANSPORT ET POLLUTION (8 questions)
    {
      "question": "🚲 Quel transport pollue le moins ?",
      "options": [
        "Le vélo",
        "La voiture",
        "L'avion"
      ],
      "answer": "Le vélo",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚶 Pourquoi marcher pour aller à l'école ?",
      "options": [
        "C'est bon pour la santé et l'environnement",
        "C'est plus lent",
        "C'est fatigant"
      ],
      "answer": "C'est bon pour la santé et l'environnement",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚌 Qu'est-ce que le covoiturage ?",
      "options": [
        "Partager une voiture à plusieurs",
        "Avoir plusieurs voitures",
        "Conduire vite"
      ],
      "answer": "Partager une voiture à plusieurs",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "✈️ Quel transport produit le plus de CO2 ?",
      "options": [
        "L'avion",
        "Le vélo",
        "Le train"
      ],
      "answer": "L'avion",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚃 Pourquoi prendre le train ?",
      "options": [
        "Il pollue moins que la voiture",
        "Il est plus rapide",
        "Il coûte moins cher"
      ],
      "answer": "Il pollue moins que la voiture",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🛴 Quelle trottinette pollue le moins ?",
      "options": [
        "Trottinette classique (sans moteur)",
        "Trottinette électrique",
        "Les deux pareil"
      ],
      "answer": "Trottinette classique (sans moteur)",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚗 Qu'est-ce que la pollution de l'air ?",
      "options": [
        "Des gaz toxiques dans l'air",
        "De l'air frais",
        "Du vent"
      ],
      "answer": "Des gaz toxiques dans l'air",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌍 Comment réduire la pollution des transports ?",
      "options": [
        "Utiliser vélo, marche ou transports en commun",
        "Utiliser plus de voitures",
        "Rester à la maison"
      ],
      "answer": "Utiliser vélo, marche ou transports en commun",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: ANIMAUX ET BIODIVERSITÉ (10 questions)
    {
      "question": "🐝 Pourquoi les abeilles sont importantes ?",
      "options": [
        "Elles pollinisent les fleurs",
        "Elles font du bruit",
        "Elles mangent les feuilles"
      ],
      "answer": "Elles pollinisent les fleurs",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🦋 Que mange un papillon ?",
      "options": [
        "Le nectar des fleurs",
        "Du plastique",
        "Des cailloux"
      ],
      "answer": "Le nectar des fleurs",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐻 Que signifie 'espèce en danger' ?",
      "options": [
        "Un animal risque de disparaître",
        "Un animal est dangereux",
        "Un animal est malade"
      ],
      "answer": "Un animal risque de disparaître",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🦉 Pourquoi certains animaux sortent la nuit ?",
      "options": [
        "Ils sont nocturnes",
        "Ils ont peur du jour",
        "Ils sont fatigués"
      ],
      "answer": "Ils sont nocturnes",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐛 Que devient une chenille ?",
      "options": [
        "Un papillon",
        "Un oiseau",
        "Une abeille"
      ],
      "answer": "Un papillon",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🦔 Comment aider les hérissons ?",
      "options": [
        "Créer des passages dans les jardins",
        "Les enfermer",
        "Les chasser"
      ],
      "answer": "Créer des passages dans les jardins",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐸 Où vivent les grenouilles ?",
      "options": [
        "Près de l'eau",
        "Dans le désert",
        "Dans les arbres uniquement"
      ],
      "answer": "Près de l'eau",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🦜 Pourquoi protéger les habitats naturels ?",
      "options": [
        "Pour que les animaux aient un lieu de vie",
        "Pour construire des maisons",
        "Ce n'est pas important"
      ],
      "answer": "Pour que les animaux aient un lieu de vie",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🐿️ Que mange un écureuil ?",
      "options": [
        "Des noisettes et des glands",
        "Du plastique",
        "Des cailloux"
      ],
      "answer": "Des noisettes et des glands",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🦌 Que signifie 'biodiversité' ?",
      "options": [
        "La variété des êtres vivants",
        "Un seul type d'animal",
        "La pollution"
      ],
      "answer": "La variété des êtres vivants",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: CLIMAT ET MÉTÉO (8 questions)
    {
      "question": "🌡️ Qu'est-ce que le réchauffement climatique ?",
      "options": [
        "La Terre devient plus chaude",
        "Il fait froid",
        "Il pleut beaucoup"
      ],
      "answer": "La Terre devient plus chaude",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "☁️ Qu'est-ce que l'effet de serre ?",
      "options": [
        "Des gaz qui retiennent la chaleur",
        "Une serre de jardin",
        "La pluie"
      ],
      "answer": "Des gaz qui retiennent la chaleur",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌪️ Pourquoi y a-t-il plus de tempêtes ?",
      "options": [
        "À cause du changement climatique",
        "C'est normal",
        "Il y en a moins"
      ],
      "answer": "À cause du changement climatique",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🧊 Que se passe-t-il avec les glaciers ?",
      "options": [
        "Ils fondent",
        "Ils grandissent",
        "Ils ne changent pas"
      ],
      "answer": "Ils fondent",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌡️ Qu'est-ce que le CO2 ?",
      "options": [
        "Un gaz à effet de serre",
        "De l'eau",
        "De l'oxygène"
      ],
      "answer": "Un gaz à effet de serre",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🔥 Pourquoi y a-t-il des feux de forêt ?",
      "options": [
        "Sécheresse et chaleur extrême",
        "Il y en a toujours eu autant",
        "C'est bien pour la forêt"
      ],
      "answer": "Sécheresse et chaleur extrême",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌊 Que se passe-t-il avec le niveau des océans ?",
      "options": [
        "Il monte",
        "Il descend",
        "Il ne change pas"
      ],
      "answer": "Il monte",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "❄️ Qu'arrive-t-il aux animaux polaires ?",
      "options": [
        "Leur habitat fond",
        "Ils vont mieux",
        "Rien de spécial"
      ],
      "answer": "Leur habitat fond",
      "image": "assets/lottie/ecology.json"
    },

    // THÈME: GESTES QUOTIDIENS (7 questions)
    {
      "question": "🛍️ Qu'utiliser pour faire les courses ?",
      "options": [
        "Un sac réutilisable",
        "Beaucoup de sacs plastiques",
        "Ses mains uniquement"
      ],
      "answer": "Un sac réutilisable",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🧴 Qu'est-ce qu'un produit écologique ?",
      "options": [
        "Un produit qui respecte l'environnement",
        "Un produit cher",
        "Un produit vert"
      ],
      "answer": "Un produit qui respecte l'environnement",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🍴 Qu'utiliser au lieu du plastique jetable ?",
      "options": [
        "Des couverts réutilisables",
        "Plus de plastique",
        "Rien"
      ],
      "answer": "Des couverts réutilisables",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🧽 Comment laver la vaisselle écologiquement ?",
      "options": [
        "Avec des produits naturels",
        "Avec beaucoup de produits chimiques",
        "Ne pas la laver"
      ],
      "answer": "Avec des produits naturels",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🎒 Que mettre dans son sac pour le goûter ?",
      "options": [
        "Une gourde et une boîte réutilisable",
        "Plein d'emballages jetables",
        "Rien"
      ],
      "answer": "Une gourde et une boîte réutilisable",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🚮 Où jeter un chewing-gum ?",
      "options": [
        "À la poubelle",
        "Par terre",
        "Dans la nature"
      ],
      "answer": "À la poubelle",
      "image": "assets/lottie/ecology.json"
    },
    {
      "question": "🌿 Quel savon choisir ?",
      "options": [
        "Savon naturel sans emballage plastique",
        "Gel douche en bouteille plastique",
        "Ne pas se laver"
      ],
      "answer": "Savon naturel sans emballage plastique",
      "image": "assets/lottie/ecology.json"
    }
  ];
  void checkAnswer(String answer) {
    setState(() {
      answered = true;
      selectedAnswer = answer;

      if (answer == questions[questionIndex]["answer"]) {
        score++;
        _controller.forward().then((value) => _controller.reverse());
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (questionIndex < questions.length - 1) {
        setState(() {
          questionIndex++;
          answered = false;
          selectedAnswer = "";
        });
      } else {
        showResult();
      }
    });
  }

  void showResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "🎉 Bravo !",
          textAlign: TextAlign.center,
        ),
        content: Text(
          "Tu as obtenu $score / ${questions.length} 🌟",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                questionIndex = 0;
                score = 0;
                answered = false;
              });
            },
            child: const Text("Rejouer"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[questionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ CENTRAGE HORIZONTAL
          children: [
            // Animation
            SizedBox(height: 20,),
            SizedBox(
              height: 180,
              child: Lottie.asset(q["image"]),
            ),

            const SizedBox(height: 10),

            // Question
            Text(
              q["question"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Options
            for (final opt in q["options"])
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: answered && opt == q["answer"]
                    ? _scaleAnim.value
                    : 1.0,
                child: GestureDetector(
                  onTap: answered ? null : () => checkAnswer(opt),
                  child: Container(
                    width: double.infinity, // ❗ optionnel (voir note ci-dessous)
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: opt == selectedAnswer
                          ? (opt == q["answer"] ? Colors.green : Colors.red)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(2, 2),
                        )
                      ],
                    ),
                    child: Text(
                      opt,
                      textAlign: TextAlign.center, // ✅ texte centré
                      style: TextStyle(
                        fontSize: 18,
                        color: opt == selectedAnswer
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

            const Spacer(),

            // Progression
            Text(
              "Question ${questionIndex + 1} / ${questions.length}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),

    );
  }
}
