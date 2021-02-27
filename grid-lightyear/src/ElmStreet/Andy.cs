// Default URL for triggering event grid function in the local environment.
// http://localhost:7071/runtime/webhooks/EventGrid?functionName={functionname}
using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.EventGrid.Models;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;
using System.Text.Json;
using ToyCollection;

namespace ElmStreet
{
    public static class Andy
    {
        [FunctionName("andy")]
        public static async Task Run([EventGridTrigger]EventGridEvent eventGridEvent, 
            [EventGrid(TopicEndpointUri = "MyEventGridTopicUriSetting", TopicKeySetting = "MyEventGridTopicKeySetting")]IAsyncCollector<EventGridEvent> outputEvents,
            ILogger log)
        {
            var data = eventGridEvent.Data.ToString();
            log.LogInformation(data);            

            var toy = JsonSerializer.Deserialize<BasicToy>(data);

            await Task.Delay(500);

            if(toy.Condition == Condition.New) 
            { 
                toy.Condition = Condition.Used;
            } 

            await outputEvents.AddAsync(new EventGridEvent {                 
                Data = toy,                
                Topic = "evgt-andys-toys",            
                Subject = "used",
                EventType = "toy-stolen",
                EventTime = DateTime.UtcNow,
                DataVersion = "1.0",
                Id = Guid.NewGuid().ToString()
            });
        }
    }
}
