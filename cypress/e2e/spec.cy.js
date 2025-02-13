
describe('Email Input Form Tests', () => {
  beforeEach(() => {
    cy.visit('http://localhost:3000'); 
  });

  it('displays an error message when the email is invalid', () => {
    // メールアドレスの入力欄を特定するセレクターを指定
    cy.get('input[name="会社名"]') ;
    cy.get('input[name="お名前"]');
    cy.get('input[name="メールアドレス"]').type('not-an-email');
    cy.get('input[name="電話番号"]');
    cy.get('input[name="送信"]').click();
    
  });

it('displays an error message when the email is invalid', () => {
  // メールアドレスの入力欄を特定するセレクターを指定
  cy.get('input[name="会社名"]') ;
  cy.get('input[name="お名前"]');
  cy.get('input[name="メールアドレス"]').type('a@sample.com');
  cy.get('input[name="電話番号"]');
  cy.get('input[name="送信"]').click();
});
})