import express from "express";
import cors from 'cors'
import rotasLivros from './routes/livros.js'
const app = express()
const port = 4000

app.use(cors()) 
app.use(express.urlencoded({extended: true}))
app.use(express.json()) 

app.use('/api/livros', rotasLivros)

app.use('/', express.static('public'))

app.get('/api', (req, res) => {
    res.status(200).json({
        mensagem: 'API 100% funcional!',
        versao: '1.0.1'
    })
})

app.use(function(req, res){
    res.status(404).json({
        mensagem: `A rota ${req.originalUrl} não existe!`
    })
})
    
    app.listen(port, function(){
        console.log(`🚀Servidor rodando na porta ${port}`)})