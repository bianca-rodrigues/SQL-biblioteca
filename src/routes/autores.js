import express from 'express'
import sql from 'mssql'
import { sqlConfig } from '../sql/config.js'

const router = express.Router()

/***************************************
 * GET /autores
 * Lista todos os autores
 ***************************************/
router.get('/', (req, res) => {
    try {
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
                .execute('SP_S_BIB_AUTORES')
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
 * POST /autores
 * Insere um novo autor
 ***************************************/
router.post('/', (req, res) => {
    sql.connect(sqlConfig).then(pool => {
        const { nome, sobrenome} = req.body
        return pool
            .request()
            .input('NOME', sql.VarChar(20), nome)
            .input('SOBRENOME', sql.VarChar(50), sobrenome)
            
            .execute('SP_I_BIB_AUTORES')
    }).then(dados => {
        res.status(200).json(dados.output)
    }).catch(err => {
        res.status(400).json(err.message)
    })
})

/**********************************************
 * PUT /autor
 * Altera um autor existente
 **********************************************/
router.put("/", (req, res) => {
    sql.connect(sqlConfig).then(pool => {
      const {id, nome, sobrenome} = req.body
          return pool
          .request()
          .input('ID', sql.Int, id)
          .input('NOME', sql.VarChar(20), nome)
          .input('SOBRENOME', sql.VarChar(50), sobrenome)
          .execute('SP_U_BIB_AUTORES')
        }).then(dados => {
          res.status(200).json('Autor alterado com sucesso!')
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
          .execute('SP_D_BIB_AUTORES')
        }).then(dados => {
          res.status(200).json('Autor excluído com sucesso!')
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
                .execute('SP_S_BIB_AUTORES')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err)
        })
    } catch (err) {
        console.error(err)
    }
})