document.addEventListener("DOMContentLoaded", () => {
  const btn = document.getElementById("search-btn")     //Guarda botão de busca, campo de input e div de resultados em variáveis
  const input = document.getElementById("search-input")
  const resultsDiv = document.getElementById("results")

  if (!btn) return

  btn.addEventListener("click", async () => {
    const title = input.value

    const response = await fetch(`/api/books/search?title=${title}`)    //Faz uma requisição http get para a rota de busca
    const books = await response.json()

    resultsDiv.innerHTML = ""

    books.forEach(book => { //Para cada livro encontrado, cria um elemento div com as informações do livro e um botão para salvar   
      const div = document.createElement("div")

      div.innerHTML = `
        <strong>${book.title}</strong> - ${book.author} (${book.year})
        <button class="save-book">Salvar</button>
      `

      div.querySelector(".save-book").addEventListener("click", () => {
        saveBook(book)
      })

      resultsDiv.appendChild(div)
    })
  })
})

async function saveBook(book) { //Função para salvar o livro no banco de dados, fazendo uma requisição http post para a rota de criação de livros
  await fetch("/books", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
    },
    body: JSON.stringify({
      book: {
        title: book.title,
        author: book.author,
        year: book.year
      }
    })
  })

  alert("Livro salvo!")
  window.location.reload()
}
