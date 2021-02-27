// Default URL for triggering event grid function in the local environment.
// http://localhost:7071/runtime/webhooks/EventGrid?functionName={functionname}
using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.EventGrid.Models;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using ToyCollection;
using System.Threading.Tasks;

namespace ElmStreet
{
    public static class Sid
    {
        [FunctionName("sid")]
        public static async Task Run([EventGridTrigger]EventGridEvent eventGridEvent, 
            [EventGrid(TopicEndpointUri = "MyEventGridTopicUriSetting", TopicKeySetting = "MyEventGridTopicKeySetting")]IAsyncCollector<EventGridEvent> outputEvents,
            ILogger log)
        {
            var data = eventGridEvent.Data.ToString();
            log.LogInformation(data);            

            var toy = JsonSerializer.Deserialize<BasicToy>(data);

            await Task.Delay(500);

            if(toy.Condition == Condition.Damaged) 
            { 
                toy.Condition = Condition.Destroyed;
                return;
            } 

            toy.Condition = Condition.Damaged;

            await outputEvents.AddAsync(new EventGridEvent {                 
                Data = toy,                
                Topic = "evgt-abused-toys",                
                Subject = "damaged",
                EventType = "toy-recovered",
                EventTime = DateTime.UtcNow,
                DataVersion = "1.0",
                Id = Guid.NewGuid().ToString()
            });
        }
    }
}
