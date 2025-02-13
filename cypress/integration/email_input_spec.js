describe('Email Input Form Tests', () => {
    beforeEach(() => {
      cy.visit('http://localhost:3000'); // ReactアプリケーションのURLに合わせてください
    });
  
    it('displays an error message when the email is invalid', () => {
      // メールアドレスの入力欄を特定するセレクターを指定
      cy.get('[data-cy=email-input]').type('not-an-email');
      cy.get('[data-cy=submit-button]').click();
      // エラーメッセージが表示されることを検証
      cy.get('[data-cy=email-error]').should('be.visible').and('contain', 'Invalid email address');
    });
  
    it('does not display an error message when the email is valid', () => {
      cy.get('[data-cy=email-input]').type('example@example.com');
      cy.get('[data-cy=submit-button]').click();
      // エラーメッセージが表示されないことを検証
      cy.get('[data-cy=email-error]').should('not.exist');
    });
  });
  
  