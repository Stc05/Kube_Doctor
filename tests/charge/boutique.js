import http from 'k6/http';
import { check, sleep } from 'k6';

// Déroulé du test : montée, palier, descente
export const options = {
  stages: [
    { duration: '1m', target: 20 },  // monter progressivement à 20 visiteurs
    { duration: '3m', target: 20 },  // rester à 20 visiteurs pendant 3 minutes
    { duration: '1m', target: 0 },   // redescendre à 0
  ],
  // Critères de réussite du test
  thresholds: {
    http_req_duration: ['p(95)<1000'], // 95 % des pages en moins d'une seconde
    http_req_failed: ['rate<0.01'],    // moins de 1 % d'erreurs
  },
};

const BASE = __ENV.BASE_URL || 'http://localhost:8080';
const PRODUITS = ['OLJCESPC7Z', '66VCHSJNUP', '1YMWWN1N4O', 'L9ECAV7KIM', '2ZYFJ3GM2N'];

// Ce que fait chaque visiteur virtuel, en boucle
export default function () {
  const accueil = http.get(`${BASE}/`);
  check(accueil, { "page d'accueil OK": (r) => r.status === 200 });

  const produit = PRODUITS[Math.floor(Math.random() * PRODUITS.length)];
  const page = http.get(`${BASE}/product/${produit}`);
  check(page, { 'page produit OK': (r) => r.status === 200 });

  sleep(1);
}
