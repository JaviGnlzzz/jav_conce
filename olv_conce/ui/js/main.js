$(() => {
    
    let modelVehicle = null    
    let modelPrice = null

    $('body').hide()

    window.addEventListener('message', function(event){
        const {action, type, data_conce, data_stats} = event.data;

        if(action == 'show:interfaz:conce'){
            if(type == 'list'){
                buildVehicles(data_conce)
                setTimeout(() => {
                    $('body').fadeIn()
                }, 800)
            };

            if(type == 'stats'){
                buildStats(data_stats);
            };
        }else{
            $('body').fadeOut(500)
        };
    })

    const buildVehicles = (data) => {

        $('.container-models').empty()

        data.forEach((item, index) => {

            if(index == 1){
                post('spawn_vehicle', {model : item.model, price : item.price})
            };

            $('.container-models').append(`
                <div class="item-model">
                    <div class="title-model">${item.name}</div>
                    <div class="price-model">${item.price}</div>
                </div>
            `);

            $('.item-model').eq(index).click(() => {
                post('spawn_vehicle', {model : item.model, price : item.price})
            });
        });
    };

    const buildStats = (data) => {

        data.forEach(item => {

            modelVehicle = null
            modelPrice = null

            const {brake, acceleration, speed, model, price} = item;

            modelVehicle = model;
            modelPrice = price;

            $('.left-container .title-container').text(model);

            $('.speed').css({'width' : speed + '%'});
            $('.brake').css({'width' : brake + '%'});
            $('.acceleration').css({'width' : acceleration + '%'});
            
        });
    };

    $('.button').click(() => {
        if(modelVehicle) {
            post('buy_vehicle', {model : modelVehicle, price : modelPrice})
        }
    })

    document.onkeyup = ({ key }) => key === 'Escape' && post('exit')

    function post(url, data, cb) {
        $.post(`https://${GetParentResourceName()}/${url}`, JSON.stringify(data) || JSON.stringify({}), cb || function() {});
    };

    $('.search-bar input').on('input', function() {
        let term = $(this).val().toLowerCase();
    
        $('.item-model').filter(function() {
            $(this).toggle($(this).text().toLowerCase().indexOf(term) > -1);
        });
    });    
    
})