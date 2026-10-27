// Small test-data helpers, loaded in features with: * def data = read('classpath:helpers/data.js')
function fn() {
  var UUID = Java.type('java.util.UUID');
  return {
    uniqueSuffix: function () {
      return UUID.randomUUID().toString().substring(0, 8);
    },
    newProduct: function (overrides) {
      var product = {
        title: 'Karate Test Product ' + UUID.randomUUID().toString().substring(0, 8),
        description: 'Created by the Karate API framework',
        price: 49.99,
        discountPercentage: 5,
        stock: 25,
        brand: 'KarateLabs',
        category: 'groceries'
      };
      return karate.merge(product, overrides || {});
    },
    roundTo2: function (n) {
      return Math.round(n * 100) / 100;
    }
  };
}
