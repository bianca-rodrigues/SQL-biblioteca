import express from 'express'
import sql from 'mssql'
import { sqlConfig } from '../sql/config.js'

const router = express.Router()

/***************************************
 * GET /livros
 * Lista todos os livros
 ***************************************/
router.get('/', (req, res) => {
    try {
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
                .execute('SP_S_BIB_LIVRO')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err)
        })
    } catch (err) {
        console.error(`Erro ao conectar: ${err.message}`)
    }
})

/***************************************
 * POST /livro
 * Insere um novo livro
 ***************************************/
router.post('/', (req, res) => {
    sql.connect(sqlConfig).then(pool => {
        const { titulo, isbn, publicacao, preco } = req.body
        return pool
            .request()
            .input('NOME', sql.VarChar(100), titulo)
            .input('ISBN', sql.VarChar(8), isbn)
            .input('PUBLICACAO', sql.Date, publicacao)
            .input('PRECO', sql.Numeric, preco)
            .execute('SP_I_BIB_LIVRO')
    }).then(dados => {
        res.status(200).json(dados.output)
    }).catch(err => {
        res.status(400).json(err.message)
    })
})

/**********************************************
 * PUT /livro
 * Altera um livro existente
 **********************************************/
router.put("/", (req, res) => {
    sql.connect(sqlConfig).then(pool => {
      const {id, titulo, isbn, publicacao, preco} = req.body
          return pool
          .request()
          .input('ID', sql.Int, id)
          .input('NOME', sql.VarChar(100), titulo)
          .input('ISBN', sql.VarChar(8), isbn)
          .input('PUBLICACAO', sql.Date, publicacao)
          .input('PRECO', sql.Numeric, preco)
          .execute('SP_U_BIB_LIVRO')
        }).then(dados => {
          res.status(200).json('Livro alterado com sucesso!')
      }).catch(err => {
          res.status(400).json(err.message) //bad request
      })
  })

  /**********************************************
 * DELETE /livro/
 * Apaga um livro pelo id
 **********************************************/
router.delete("/:id", (req, res) => {
    sql.connect(sqlConfig).then(pool => {
      const id = req.params.id
          return pool.request()
          .input('ID', sql.Int, id)
          .execute('SP_D_BIB_LIVRO')
        }).then(dados => {
          res.status(200).json('Livro excluído com sucesso!')
      }).catch(err => {
          res.status(400).json(err.message)
      })
  })

  /**********************************************
 * GET /lvrio
 * Lista um único livro pelo id
 **********************************************/
router.get("/:id", (req, res) => {
    const id = req.params.id
    try {
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
                .input('FILTRO', sql.Int, id)
                .execute('SP_S_BIB_LIVRO')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err)
        })
    } catch (err) {
        console.error(err)
    }
})

export default router

