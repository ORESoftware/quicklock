import suman = require('suman');
const Test = suman.init(module);

Test.create('fage', b => {
  
  const {describe, it} = b.getHooks();
  
  describe('foo', b => {
    
    it('is cool', t => {
      t.assert(true);
    });
    
  });
  
});
